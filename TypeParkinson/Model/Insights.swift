import Foundation
import SwiftUI

/// A finding from the person's own history, in plain words.
struct Insight: Identifiable, Equatable {
    var id: String
    var symbol: String
    var color: Color
    var title: String
    var detail: String
}

/// Looks for patterns in the history: trends, the steadiest time of day, how
/// timing after a dose relates to touches, and how feelings match the numbers.
/// Only says something when there's enough data behind it.
enum InsightEngine {
    static func insights(log: ActivityLog, now: Date = .now, calendar: Calendar = .current) -> [Insight] {
        var found: [Insight] = []
        let checks = log.checkIns.filter { !$0.isSetup }

        // Week over week: average distance from target.
        let thisWeek = checks.filter { $0.date > now.addingTimeInterval(-7 * 86_400) }.map(\.distance)
        let lastWeek = checks.filter { $0.date <= now.addingTimeInterval(-7 * 86_400) && $0.date > now.addingTimeInterval(-14 * 86_400) }.map(\.distance)
        if thisWeek.count >= 3, lastWeek.count >= 3 {
            let change = (lastWeek.mean - thisWeek.mean) / max(lastWeek.mean, 0.1)
            if abs(change) >= 0.08 {
                found.append(Insight(
                    id: "week",
                    symbol: change > 0 ? "arrow.down.right.circle.fill" : "arrow.up.right.circle.fill",
                    color: change > 0 ? Theme.positive : Theme.warning,
                    title: change > 0 ? "Touches landed \(Int((change * 100).rounded()))% closer this week"
                                      : "Touches landed \(Int((-change * 100).rounded()))% further off this week",
                    detail: "Compared with the week before, from your daily checks."))
            }
        }

        // Medication timing.
        if let timing = doseTiming(checks: checks, doses: log.doses) {
            found.append(timing)
        }

        // Time of day.
        let buckets = Dictionary(grouping: checks) { check -> String in
            let hour = calendar.component(.hour, from: check.date)
            return hour < 12 ? "morning" : hour < 17 ? "afternoon" : "evening"
        }.filter { $0.value.count >= 2 }
        if buckets.count >= 2, checks.count >= 6,
           let best = buckets.min(by: { $0.value.map(\.distance).mean < $1.value.map(\.distance).mean }),
           let worst = buckets.max(by: { $0.value.map(\.distance).mean < $1.value.map(\.distance).mean }),
           worst.value.map(\.distance).mean - best.value.map(\.distance).mean > 0.8 {
            found.append(Insight(
                id: "time",
                symbol: best.key == "morning" ? "sunrise.fill" : best.key == "afternoon" ? "sun.max.fill" : "moon.stars.fill",
                color: Theme.voiceColor,
                title: "You’re steadiest in the \(best.key)",
                detail: "Touches land \((worst.value.map(\.distance).mean - best.value.map(\.distance).mean).oneDecimal) pt closer than in the \(worst.key), on average."))
        }

        // Feelings match the numbers.
        let felt = checks.filter { $0.feeling != nil }
        let good = felt.filter { ($0.feeling?.rawValue ?? 0) >= 3 }.map(\.distance)
        let hard = felt.filter { ($0.feeling?.rawValue ?? 0) <= 2 }.map(\.distance)
        if good.count >= 3, hard.count >= 3, hard.mean - good.mean > 0.8 {
            found.append(Insight(
                id: "feeling",
                symbol: "heart.text.square.fill",
                color: Theme.typingColor,
                title: "Your sense of a good day is right",
                detail: "On days typing felt good, touches landed \((hard.mean - good.mean).oneDecimal) pt closer than on harder days."))
        }

        // Spiral smoothness trend.
        let spirals = log.spirals.suffix(10)
        if spirals.count >= 4 {
            let half = spirals.count / 2
            let early = spirals.prefix(half).map(\.result.smoothness).mean
            let late = spirals.suffix(half).map(\.result.smoothness).mean
            if late - early >= 0.03 {
                found.append(Insight(id: "spiral", symbol: "hurricane", color: Theme.spiralColor,
                                     title: "Smoother spirals lately",
                                     detail: "Smoothness is up \(Int(((late - early) * 100).rounded())) points across your recent drawings."))
            }
        }

        // Voice.
        let voice = log.voice.suffix(8)
        if voice.count >= 4 {
            let half = voice.count / 2
            let early = voice.prefix(half).map(\.result.inTarget).mean
            let late = voice.suffix(half).map(\.result.inTarget).mean
            if late - early >= 0.1 {
                found.append(Insight(id: "voice", symbol: "mic.fill", color: Theme.voiceColor,
                                     title: "Your voice is holding the target longer",
                                     detail: "\(Int((late * 100).rounded()))% of each “ahh” is now in the loud zone, up from \(Int((early * 100).rounded()))%."))
            }
        }
        return found
    }

    /// When are touches steadiest relative to the last dose? Needs at least two
    /// checks in each of two timing windows.
    static func doseTiming(checks: [CheckInRecord], doses: [DoseRecord]) -> Insight? {
        guard doses.count >= 4, checks.count >= 6 else { return nil }
        let sortedDoses = doses.map(\.date).sorted()
        var windows: [String: [Double]] = [:]
        for check in checks {
            guard let last = sortedDoses.last(where: { $0 <= check.date }) else { continue }
            let hours = check.date.timeIntervalSince(last) / 3600
            let key = hours < 1 ? "within an hour" : hours < 3 ? "1–3 hours" : hours < 5 ? "3–5 hours" : "over 5 hours"
            windows[key, default: []].append(check.distance)
        }
        let usable = windows.filter { $0.value.count >= 2 }
        guard usable.count >= 2,
              let best = usable.min(by: { $0.value.mean < $1.value.mean }),
              let worst = usable.max(by: { $0.value.mean < $1.value.mean }),
              worst.value.mean - best.value.mean > 0.8 else { return nil }
        return Insight(
            id: "dose",
            symbol: "pills.fill",
            color: Theme.medsColor,
            title: best.key == "within an hour" ? "Steadiest soon after a dose" : "Steadiest \(best.key) after a dose",
            detail: "Touches landed \((worst.value.mean - best.value.mean).oneDecimal) pt closer than \(worst.key) after one. Worth showing your doctor.")
    }
}

// MARK: - Achievements

struct Achievement: Identifiable, Equatable {
    var id: String
    var title: String
    var detail: String
    var symbol: String
    var colors: [Color]
    /// 0 to 1; 1 is earned.
    var progress: Double

    var earned: Bool { progress >= 1 }
}

enum Achievements {
    static func all(log: ActivityLog, streak: Int, phrases: Int) -> [Achievement] {
        let practice = log.spirals.count + log.tapping.count + log.typing.count + log.tremor.count + log.voice.count
        let checks = log.checkIns.filter { !$0.isSetup }.count
        let smooth = log.spirals.contains { $0.result.smoothness >= 0.9 }
        let loud = log.voice.contains { $0.result.inTarget >= 0.8 }
        func ratio(_ n: Int, _ goal: Int) -> Double { min(1, Double(n) / Double(goal)) }
        return [
            Achievement(id: "first-check", title: "First check", detail: "Do a daily check", symbol: "hand.tap.fill",
                        colors: [Color(rgb: 0x3D6BFF), Color(rgb: 0x1A36A8)], progress: ratio(checks, 1)),
            Achievement(id: "streak-3", title: "3-day streak", detail: "Three days in a row", symbol: "flame.fill",
                        colors: [Color(rgb: 0xFF9A3D), Color(rgb: 0xE5482E)], progress: ratio(streak, 3)),
            Achievement(id: "streak-7", title: "Full week", detail: "Seven days in a row", symbol: "calendar",
                        colors: [Color(rgb: 0xFFB020), Color(rgb: 0xF06A1F)], progress: ratio(streak, 7)),
            Achievement(id: "streak-30", title: "Month strong", detail: "Thirty days in a row", symbol: "crown.fill",
                        colors: [Color(rgb: 0xFFD54D), Color(rgb: 0xD99500)], progress: ratio(streak, 30)),
            Achievement(id: "smooth", title: "Smooth operator", detail: "A spiral at 90% smoothness", symbol: "hurricane",
                        colors: [Color(rgb: 0x16C7BE), Color(rgb: 0x0A6E8A)], progress: smooth ? 1 : 0),
            Achievement(id: "practice-25", title: "Regular", detail: "25 practice sessions", symbol: "figure.mind.and.body",
                        colors: [Color(rgb: 0xF0468E), Color(rgb: 0x8E2BB8)], progress: ratio(practice, 25)),
            Achievement(id: "loud", title: "Loud and clear", detail: "80% of an “ahh” in the loud zone", symbol: "speaker.wave.3.fill",
                        colors: [Color(rgb: 0xFFC14D), Color(rgb: 0xE07A00)], progress: loud ? 1 : 0),
            Achievement(id: "tremor", title: "Measured", detail: "Take a tremor reading", symbol: "waveform.path.ecg",
                        colors: [Color(rgb: 0x8C6CFF), Color(rgb: 0x3B2BB8)], progress: ratio(log.tremor.count, 1)),
            Achievement(id: "phrases", title: "In my words", detail: "Save 8 phrases", symbol: "text.bubble.fill",
                        colors: [Color(rgb: 0x2BD48F), Color(rgb: 0x0F8A5A)], progress: ratio(phrases, 8)),
        ]
    }
}
