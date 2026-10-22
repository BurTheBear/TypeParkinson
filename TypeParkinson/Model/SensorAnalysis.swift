import Foundation

// MARK: - Tremor meter

/// How the phone was held for a tremor reading.
enum TremorPosture: String, Codable, CaseIterable, Identifiable {
    /// Resting in the palm, hand on the lap.
    case rest
    /// Held out in front, arm straight.
    case hold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rest: "Resting"
        case .hold: "Arm out"
        }
    }

    var instruction: String {
        switch self {
        case .rest: "Rest your hand on your lap with the phone lying in your palm. Let your arm relax completely."
        case .hold: "Hold the phone in front of you with your arm straight out, as steady as you can."
        }
    }
}

/// What ten seconds of motion-sensor data showed. Describes the movement
/// only: it isn't a clinical rating and says nothing about any condition.
struct TremorResult: Codable, Equatable {
    /// The rate the hand shook at most strongly, in hertz (shakes per second).
    var frequency: Double
    /// How far the shake moved the phone at that rate, in thousandths of g.
    var amplitude: Double
    var posture: TremorPosture
    var duration: Double
    /// Strength at each frequency from 1 to 15 Hz in 0.5 Hz steps, for the chart.
    var spectrum: [Double]

    static let spectrumFrequencies: [Double] = stride(from: 1.0, through: 15.0, by: 0.5).map { $0 }

    /// A plain description of the shake.
    var summary: String {
        if amplitude < 4 { return "Very little shake." }
        switch frequency {
        case ..<3: return "A slow, uneven sway."
        case 3..<7.5: return "A slow, rhythmic shake."
        case 7.5..<12.5: return "A fast, fine shake."
        default: return "A quick, irregular jitter."
        }
    }

    var strengthLabel: String {
        switch amplitude {
        case ..<4: "Very slight"
        case 4..<15: "Slight"
        case 15..<40: "Moderate"
        default: "Strong"
        }
    }
}

enum TremorAnalysis {
    static let sampleRate = 100.0
    static let duration = 10.0

    /// Finds the strongest rhythmic movement in three axes of acceleration (in g):
    /// remove each axis's average, apply a Hann window, and measure the strength
    /// at each frequency with a discrete Fourier transform.
    static func analyze(x: [Double], y: [Double], z: [Double], sampleRate: Double = sampleRate,
                        posture: TremorPosture) -> TremorResult {
        let n = min(x.count, y.count, z.count)
        guard n >= Int(sampleRate * 2) else {
            return TremorResult(frequency: 0, amplitude: 0, posture: posture, duration: Double(n) / sampleRate,
                                spectrum: TremorResult.spectrumFrequencies.map { _ in 0 })
        }
        let axes = [Array(x.prefix(n)), Array(y.prefix(n)), Array(z.prefix(n))].map(prepared)
        // Amplitude of a sine from its windowed DFT: |X| · 4 / N (the Hann window halves the gain).
        func amplitude(at f: Double) -> Double {
            var total = 0.0
            for axis in axes {
                let a = magnitude(axis, frequency: f, sampleRate: sampleRate) * 4 / Double(n)
                total += a * a
            }
            return sqrt(total)
        }
        // Search 2–15 Hz finely for the peak; voluntary movement sits below 2 Hz.
        var bestF = 2.0, bestA = 0.0
        for f in stride(from: 2.0, through: 15.0, by: 0.1) {
            let a = amplitude(at: f)
            if a > bestA { bestA = a; bestF = f }
        }
        let spectrum = TremorResult.spectrumFrequencies.map { amplitude(at: $0) * 1000 }
        return TremorResult(frequency: (bestF * 10).rounded() / 10, amplitude: bestA * 1000, posture: posture,
                            duration: Double(n) / sampleRate, spectrum: spectrum)
    }

    private static func prepared(_ signal: [Double]) -> [Double] {
        let mean = signal.mean
        let n = Double(signal.count)
        return signal.enumerated().map { i, v in
            let hann = 0.5 - 0.5 * cos(2 * .pi * Double(i) / (n - 1))
            return (v - mean) * hann
        }
    }

    private static func magnitude(_ signal: [Double], frequency f: Double, sampleRate: Double) -> Double {
        let w = 2 * Double.pi * f / sampleRate
        var re = 0.0, im = 0.0
        for (i, v) in signal.enumerated() {
            re += v * cos(w * Double(i))
            im -= v * sin(w * Double(i))
        }
        return sqrt(re * re + im * im)
    }

    /// A believable ten-second recording for the simulator, which has no motion sensors.
    static func simulated(posture: TremorPosture, frequency: Double = 5.2, amplitude: Double = 0.03)
        -> (x: [Double], y: [Double], z: [Double]) {
        let n = Int(sampleRate * duration)
        let strength = posture == .rest ? amplitude : amplitude * 0.6
        var x: [Double] = [], y: [Double] = [], z: [Double] = []
        for i in 0..<n {
            let t = Double(i) / sampleRate
            let wobble = 1 + 0.25 * sin(2 * .pi * 0.3 * t)
            x.append(strength * wobble * sin(2 * .pi * frequency * t) + Double.random(in: -0.004...0.004))
            y.append(0.6 * strength * wobble * sin(2 * .pi * frequency * t + 0.8) + Double.random(in: -0.004...0.004))
            z.append(0.01 * sin(2 * .pi * 0.4 * t) + Double.random(in: -0.003...0.003))
        }
        return (x, y, z)
    }
}

// MARK: - Voice

/// One "say ahh" exercise: how loud, how steady, and how long the voice held
/// in the target zone. Levels are relative to the phone's microphone, not
/// calibrated decibels.
struct VoiceResult: Codable, Equatable {
    /// Average loudness while voicing, 0 to 1.
    var level: Double
    /// Share of the voiced time spent at or above the target.
    var inTarget: Double
    /// 1 is a perfectly even voice; wavering lowers it.
    var steadiness: Double
    /// Seconds the voice was sustained.
    var duration: Double

    var score: Int { Int((level * 100).rounded()) }
}

enum VoiceAnalysis {
    /// The loudness to aim for: comfortably louder than everyday talking.
    static let target = 0.62
    /// Below this the microphone is hearing the room, not a voice.
    static let voicedFloor = 0.25
    static let duration = 6.0

    /// Microphone power in dBFS (−160…0) to a 0–1 loudness: −60 dB and below is 0.
    static func level(fromDecibels db: Double) -> Double {
        min(1, max(0, (db + 60) / 60))
    }

    /// `levels` sampled every `interval` seconds.
    static func analyze(_ levels: [Double], interval: Double) -> VoiceResult {
        let voiced = levels.filter { $0 >= voicedFloor }
        guard voiced.count >= 3 else {
            return VoiceResult(level: levels.max() ?? 0, inTarget: 0, steadiness: 0, duration: 0)
        }
        let mean = voiced.mean
        let sd = sqrt(voiced.map { pow($0 - mean, 2) }.mean)
        return VoiceResult(level: mean,
                           inTarget: Double(voiced.filter { $0 >= target }.count) / Double(voiced.count),
                           steadiness: max(0, min(1, 1 - sd / max(mean, 0.01) * 2)),
                           duration: Double(voiced.count) * interval)
    }
}
