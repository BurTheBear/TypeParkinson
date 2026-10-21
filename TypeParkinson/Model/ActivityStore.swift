import Foundation
import Observation

/// How typing felt, in the person's own words. Recorded with each daily check.
enum Feeling: Int, Codable, CaseIterable, Identifiable {
    case hard = 1, soSo, good, great

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .hard: "Hard"
        case .soSo: "So-so"
        case .good: "Good"
        case .great: "Great"
        }
    }

    var symbol: String {
        switch self {
        case .hard: "cloud.rain"
        case .soSo: "cloud"
        case .good: "cloud.sun"
        case .great: "sun.max"
        }
    }
}

/// One daily check (six taps), or the ten taps from setup.
struct CheckInRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var tapCount: Int
    var offsetX: Double
    var offsetY: Double
    /// Average distance from the centre of the target, in points.
    var distance: Double
    /// How tightly the taps cluster around their own average (root mean square), in points.
    var spread: Double
    var hitRate: Double
    var feeling: Feeling?
    var adjustedKeyboard: Bool
    var isSetup = false

    init(date: Date = .now, taps: [TapSample], feeling: Feeling?, adjustedKeyboard: Bool, isSetup: Bool = false) {
        let mean = taps.meanOffset
        self.date = date
        tapCount = taps.count
        offsetX = mean.dx
        offsetY = mean.dy
        distance = taps.map { hypot($0.dx, $0.dy) }.mean
        spread = sqrt(taps.map { pow($0.dx - mean.dx, 2) + pow($0.dy - mean.dy, 2) }.mean)
        hitRate = taps.isEmpty ? 0 : Double(taps.filter(\.hit).count) / Double(taps.count)
        self.feeling = feeling
        self.adjustedKeyboard = adjustedKeyboard
        self.isSetup = isSetup
    }
}

struct SpiralRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var hand: Hand
    var result: SpiralResult
    /// The drawing, scaled so the spiral's outer radius is 1, as x, y pairs. At most 160 points.
    var trace: [Double]
}

struct TappingRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var hand: Hand
    var result: TappingResult
}

struct TremorRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var hand: Hand
    var result: TremorResult
}

struct VoiceRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var result: VoiceResult
}

struct TypingRecord: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var phrase: String
    var wordsPerMinute: Double
    var accuracy: Double
    var corrections: Int
}

/// Everything the person has done, kept on this device only.
struct ActivityLog: Codable, Equatable {
    var checkIns: [CheckInRecord] = []
    var spirals: [SpiralRecord] = []
    var tapping: [TappingRecord] = []
    var typing: [TypingRecord] = []
    var tremor: [TremorRecord] = []
    var voice: [VoiceRecord] = []
    var doses: [DoseRecord] = []

    init() {}

    var isEmpty: Bool {
        checkIns.isEmpty && spirals.isEmpty && tapping.isEmpty && typing.isEmpty && tremor.isEmpty && voice.isEmpty
    }

    /// Days with an exercise, check or practice (doses don't count towards a streak).
    var allDates: [Date] {
        checkIns.map(\.date) + spirals.map(\.date) + tapping.map(\.date) + typing.map(\.date)
            + tremor.map(\.date) + voice.map(\.date)
    }

    /// Practice of any kind, for the daily Practice ring.
    var practiceDates: [Date] {
        spirals.map(\.date) + tapping.map(\.date) + typing.map(\.date) + tremor.map(\.date)
    }

    private enum CodingKeys: String, CodingKey {
        case checkIns, spirals, tapping, typing, tremor, voice, doses
    }

    /// Lists added in later versions are simply empty in an older file.
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        checkIns = try c.decodeIfPresent([CheckInRecord].self, forKey: .checkIns) ?? []
        spirals = try c.decodeIfPresent([SpiralRecord].self, forKey: .spirals) ?? []
        tapping = try c.decodeIfPresent([TappingRecord].self, forKey: .tapping) ?? []
        typing = try c.decodeIfPresent([TypingRecord].self, forKey: .typing) ?? []
        tremor = try c.decodeIfPresent([TremorRecord].self, forKey: .tremor) ?? []
        voice = try c.decodeIfPresent([VoiceRecord].self, forKey: .voice) ?? []
        doses = try c.decodeIfPresent([DoseRecord].self, forKey: .doses) ?? []
    }
}

/// Saves the activity log as a file in Application Support. Not synced: it can
/// grow, and it's a personal record rather than something the keyboard needs.
@Observable
final class ActivityStore {
    private(set) var log: ActivityLog
    @ObservationIgnored private let url: URL?

    /// The app's store. The reminder's "Took it" button writes here even when the app isn't open.
    static let shared = ActivityStore()

    init(url: URL? = ActivityStore.defaultURL) {
        self.url = url
        if let url, let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode(ActivityLog.self, from: data) {
            log = saved
        } else {
            log = ActivityLog()
        }
    }

    static var defaultURL: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("activity.json")
    }

    var checkIns: [CheckInRecord] { log.checkIns }
    var spirals: [SpiralRecord] { log.spirals }
    var tapping: [TappingRecord] { log.tapping }
    var typing: [TypingRecord] { log.typing }

    func add(_ record: CheckInRecord) { log.checkIns.append(record); save() }
    func add(_ record: SpiralRecord) { log.spirals.append(record); save() }
    func add(_ record: TappingRecord) { log.tapping.append(record); save() }
    func add(_ record: TypingRecord) { log.typing.append(record); save() }
    func add(_ record: TremorRecord) { log.tremor.append(record); save() }
    func add(_ record: VoiceRecord) { log.voice.append(record); save() }
    func add(_ record: DoseRecord) { log.doses.append(record); save() }

    /// Re-reads the file, for changes made while the app was in the background.
    func reload() {
        guard let url, let data = try? Data(contentsOf: url),
              let saved = try? JSONDecoder().decode(ActivityLog.self, from: data), saved != log else { return }
        log = saved
    }

    func replace(with log: ActivityLog) {
        self.log = log
        save()
    }

    func clear() {
        log = ActivityLog()
        if let url { try? FileManager.default.removeItem(at: url) }
    }

    /// Today's most recent daily check (setup taps don't count as a check-in).
    func latestCheckIn(on day: Date = .now, calendar: Calendar = .current) -> CheckInRecord? {
        checkIns.last { !$0.isSetup && calendar.isDate($0.date, inSameDayAs: day) }
    }

    func activeDays(calendar: Calendar = .current) -> Set<Date> {
        Set(log.allDates.map { calendar.startOfDay(for: $0) })
    }

    func streak(now: Date = .now, calendar: Calendar = .current) -> Int {
        Self.streak(days: activeDays(calendar: calendar), now: now, calendar: calendar)
    }

    /// Consecutive days with any activity, counting back from today. A day not
    /// done yet doesn't break the streak until it's over.
    static func streak(days: Set<Date>, now: Date, calendar: Calendar) -> Int {
        var day = calendar.startOfDay(for: now)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day), days.contains(yesterday) else { return 0 }
            day = yesterday
        }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    private func save() {
        guard let url else { return }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(log)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            // Losing one record is better than interrupting an exercise with an error.
        }
    }
}

// MARK: - Sample history

#if DEBUG
extension ActivityLog {
    /// Three weeks of plausible history, so Progress has something to show in demos.
    /// Debug builds only: real people only ever see their own data.
    static func sample(now: Date = .now, calendar: Calendar = .current) -> ActivityLog {
        var log = ActivityLog()
        var generator = SeededGenerator(seed: 7)
        func noise(_ scale: Double) -> Double { (Double.random(in: -1...1, using: &generator)) * scale }
        let medID = UUID(uuidString: "6E0C4F3A-6B1C-4C5B-9C55-7A1A0F6B2D11") ?? UUID()
        for daysAgo in stride(from: 27, through: 1, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: now)) else { continue }
            let progress = 1 - Double(daysAgo) / 27
            // Doses at 8:00 and 14:00.
            for hour in [8.0, 14.0] {
                log.doses.append(DoseRecord(date: day.addingTimeInterval(hour * 3600 + noise(600)), medicationID: medID, name: "Carbidopa-levodopa"))
            }
            // Checks alternate between mid-morning (1–2 h after a dose) and evening (5 h after).
            let evening = daysAgo % 3 == 0
            let checkTime = day.addingTimeInterval((evening ? 19.2 : 9.5) * 3600 + noise(1500))
            let wearingOff = evening ? 2.6 : 0
            if daysAgo % 7 != 4 {
                let taps = (0..<6).map { i in
                    TapSample(isCluster: false, dx: 8 - 3 * progress + wearingOff + noise(3.5), dy: 5 - 2 * progress + wearingOff / 2 + noise(3.5),
                              hit: i % 3 != 0 || progress > 0.6)
                }
                let feeling = Feeling(rawValue: min(4, max(1, Int((2 + 1.6 * progress - (evening ? 0.8 : 0) + noise(0.7)).rounded()))))
                log.checkIns.append(CheckInRecord(date: checkTime, taps: taps, feeling: feeling, adjustedKeyboard: evening))
            }
            let morning = day.addingTimeInterval(10 * 3600 + noise(1200))
            if daysAgo % 2 == 0 {
                log.spirals.append(SpiralRecord(
                    date: morning, hand: .right,
                    result: SpiralResult(deviation: 9 - 3.5 * progress + noise(1.0), smoothness: 0.76 + 0.13 * progress + noise(0.025),
                                         speed: 95 + 20 * progress + noise(8), duration: 11 - 2 * progress + noise(0.8), coverage: 1),
                    trace: []))
            }
            if daysAgo % 3 == 1 {
                let taps = Int(33 + 9 * progress + noise(2.5))
                log.tapping.append(TappingRecord(
                    date: morning.addingTimeInterval(600), hand: .right,
                    result: TappingResult(taps: taps, hits: taps - Int(4 - 3 * progress), duration: 10,
                                          consistency: 0.68 + 0.16 * progress + noise(0.035), meanInterval: 10 / Double(taps))))
            }
            if daysAgo % 2 == 1 {
                log.typing.append(TypingRecord(date: morning.addingTimeInterval(900), phrase: "sample",
                                               wordsPerMinute: 10.5 + 5.5 * progress + noise(1.0),
                                               accuracy: 0.85 + 0.11 * progress + noise(0.02), corrections: Int(6 - 4 * progress)))
            }
            if daysAgo % 3 == 2 {
                let amp = 0.034 - 0.012 * progress + noise(0.004)
                let spectrum = TremorResult.spectrumFrequencies.map { f in 1000 * amp * exp(-pow(f - 5.2, 2) / 0.6) + 0.6 }
                log.tremor.append(TremorRecord(date: morning.addingTimeInterval(1200), hand: .right,
                                               result: TremorResult(frequency: 5.2 + noise(0.3), amplitude: amp * 1000, posture: .rest,
                                                                    duration: 10, spectrum: spectrum)))
            }
            if daysAgo % 2 == 0 {
                log.voice.append(VoiceRecord(date: morning.addingTimeInterval(1500),
                                             result: VoiceResult(level: 0.5 + 0.17 * progress + noise(0.03),
                                                                 inTarget: 0.3 + 0.45 * progress + noise(0.05),
                                                                 steadiness: 0.66 + 0.15 * progress + noise(0.03), duration: 5.5)))
            }
        }
        return log
    }
}

/// Repeatable randomness, so the sample history looks the same every run.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed &* 6364136223846793005 &+ 1 }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
#endif
