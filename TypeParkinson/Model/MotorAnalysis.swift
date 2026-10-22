import CoreGraphics
import Foundation

/// A touch sample with its time, for drawings.
struct TimedPoint: Equatable {
    var x: Double
    var y: Double
    var t: TimeInterval

    var point: CGPoint { CGPoint(x: x, y: y) }
}

// MARK: - Spiral

/// What one spiral drawing measured. Describes the drawing only: it isn't a
/// clinical rating and says nothing about any condition.
struct SpiralResult: Codable, Equatable {
    /// Average distance of the line from the printed spiral, in points.
    var deviation: Double
    /// 1 is a perfectly even line; wobble lowers it.
    var smoothness: Double
    /// Points per second along the drawn line.
    var speed: Double
    var duration: Double
    /// How far along the spiral the drawing got, 0 to 1.
    var coverage: Double
}

/// The spiral exercise. Tracing an Archimedean spiral is a long-standing way to
/// look at hand steadiness: wobble shows up as a jagged line and as drift off the
/// path. The idea and the speed and smoothness features come from published
/// spiral-drawing research (see the README); the scoring here is our own.
enum Spiral {
    static let turns = 3.0

    /// Points along r = b·θ from the centre outwards, ending at `radius`.
    static func template(center: CGPoint, radius: Double, samples: Int = 720) -> [CGPoint] {
        let maxTheta = turns * 2 * .pi
        let b = radius / maxTheta
        return (0...samples).map { i in
            let theta = maxTheta * Double(i) / Double(samples)
            let r = b * theta
            return CGPoint(x: center.x + r * cos(theta), y: center.y + r * sin(theta))
        }
    }

    /// `nil` when there's too little drawing to say anything.
    static func analyze(_ trace: [TimedPoint], center: CGPoint, radius: Double) -> SpiralResult? {
        guard trace.count >= 8, radius > 0 else { return nil }
        let path = template(center: center, radius: radius)

        var distances: [Double] = []
        var furthest = 0
        for p in trace {
            var best = Double.infinity, bestIndex = 0
            for (i, q) in path.enumerated() {
                let d = hypot(p.x - q.x, p.y - q.y)
                if d < best { best = d; bestIndex = i }
            }
            distances.append(best)
            // Only count progress along the spiral while the finger is near it.
            if best < max(24, radius * 0.12) { furthest = max(furthest, bestIndex) }
        }

        let length = pathLength(trace.map(\.point))
        let duration = max(0.001, (trace.last?.t ?? 0) - (trace.first?.t ?? 0))
        return SpiralResult(
            deviation: distances.mean,
            smoothness: smoothness(trace.map(\.point)),
            speed: length / duration,
            duration: duration,
            coverage: Double(furthest) / Double(path.count - 1)
        )
    }

    /// How much of the line's length is wobble: the length of a gently smoothed
    /// copy divided by the length of the line as drawn. Jitter adds length that
    /// smoothing removes, so a shaky line scores lower.
    static func smoothness(_ points: [CGPoint], window: Int = 9) -> Double {
        guard points.count > window else { return 1 }
        let half = window / 2
        var smoothed: [CGPoint] = []
        smoothed.reserveCapacity(points.count)
        for i in points.indices {
            let lo = max(0, i - half), hi = min(points.count - 1, i + half)
            var sx: CGFloat = 0, sy: CGFloat = 0
            for p in points[lo...hi] {
                sx += p.x
                sy += p.y
            }
            let n = CGFloat(hi - lo + 1)
            smoothed.append(CGPoint(x: sx / n, y: sy / n))
        }
        let raw = pathLength(points)
        guard raw > 0 else { return 1 }
        return min(1, pathLength(smoothed) / raw)
    }

    static func pathLength(_ points: [CGPoint]) -> Double {
        var length = 0.0
        for i in points.indices.dropFirst() {
            let a = points[i - 1], b = points[i]
            length += Double(hypot(b.x - a.x, b.y - a.y))
        }
        return length
    }

    /// The drawing scaled to the spiral (outer radius 1), thinned to at most `limit` points, as x, y pairs.
    static func normalized(_ trace: [TimedPoint], center: CGPoint, radius: Double, limit: Int = 160) -> [Double] {
        guard !trace.isEmpty, radius > 0 else { return [] }
        let step = max(1, Int((Double(trace.count) / Double(limit)).rounded(.up)))
        var values: [Double] = []
        for i in stride(from: 0, to: trace.count, by: step) {
            let x: Double = (trace[i].x - Double(center.x)) / radius
            let y: Double = (trace[i].y - Double(center.y)) / radius
            values.append((x * 1000).rounded() / 1000)
            values.append((y * 1000).rounded() / 1000)
        }
        return values
    }
}

// MARK: - Tapping

/// Alternate taps between two targets for ten seconds.
struct TappingResult: Codable, Equatable {
    var taps: Int
    /// Taps inside the right target, in the right order.
    var hits: Int
    var duration: Double
    /// 1 is a perfectly even rhythm; uneven gaps between taps lower it.
    var consistency: Double
    var meanInterval: Double

    var accuracy: Double { taps == 0 ? 0 : Double(hits) / Double(taps) }
    var tapsPerTenSeconds: Double { duration > 0 ? Double(taps) / duration * 10 : 0 }
}

struct TapEvent: Equatable {
    var time: TimeInterval
    var hit: Bool
}

enum Tapping {
    static let duration: TimeInterval = 10

    static func analyze(_ events: [TapEvent], duration: TimeInterval = Tapping.duration) -> TappingResult {
        let times = events.map(\.time)
        let intervals = zip(times, times.dropFirst()).map { $1 - $0 }.filter { $0 > 0 }
        let mean = intervals.mean
        let consistency: Double
        if intervals.count >= 3, mean > 0 {
            let sd = sqrt(intervals.map { pow($0 - mean, 2) }.mean)
            consistency = max(0, min(1, 1 - sd / mean))
        } else {
            consistency = 0
        }
        return TappingResult(taps: events.count, hits: events.filter(\.hit).count, duration: duration,
                             consistency: consistency, meanInterval: mean)
    }
}

// MARK: - Typing

enum TypingScore {
    /// Standard words per minute: five characters make a word.
    static func wordsPerMinute(characters: Int, seconds: Double) -> Double {
        guard seconds > 0.5 else { return 0 }
        return Double(characters) / 5 / (seconds / 60)
    }

    static func accuracy(errors: Int, length: Int) -> Double {
        guard length > 0 else { return 0 }
        return max(0, 1 - Double(errors) / Double(length))
    }
}

/// Short, everyday phrases for typing practice. No pangram drills: people type messages.
enum PracticePhrases {
    static let all = [
        "see you at the park at four",
        "thank you for the lovely card",
        "can you pick up some milk",
        "the weather is nice today",
        "call me when you get home",
        "dinner is at six tonight",
        "i will be there in ten minutes",
        "happy birthday to my best friend",
        "the doctor moved my visit to friday",
        "please send me the photos",
        "we had a great walk this morning",
        "let us meet for coffee soon",
    ]

    static func random(excluding previous: String? = nil) -> String {
        all.filter { $0 != previous }.randomElement() ?? all[0]
    }
}
