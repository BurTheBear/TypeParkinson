import CoreGraphics
import Foundation

enum Hand: String, Codable, CaseIterable, Identifiable {
    case right = "Right hand"
    case left = "Left hand"
    case both = "Both / varies"

    var id: String { rawValue }
}

struct TapSample: Codable, Equatable {
    var isCluster: Bool
    /// Where the touch landed relative to the centre of the intended target, in points.
    var dx: Double
    var dy: Double
    var hit: Bool
}

struct DoubleTapSample: Codable, Equatable {
    var interval: Double
    var contacts: Int
}

struct HoldSample: Codable, Equatable {
    var duration: Double
    var movement: Double
}

struct PhraseResult: Codable, Equatable {
    var errors: Int
    var corrections: Int
    var time: Double
}

struct Finding: Hashable {
    var text: String
    var detail: String
}

/// What the five exercises measured. `nil` means the exercise was skipped.
struct TouchProfile: Codable, Equatable {
    var hand: Hand = .right
    var taps: [TapSample] = []
    var doubleTaps: [DoubleTapSample]?
    var holds: [HoldSample]?
    var pathDeviation: Double?
    var phrase: PhraseResult?

    var meanOffset: CGVector { taps.meanOffset }

    var singleHitRate: Double { hitRate(taps.filter { !$0.isCluster }) }
    var clusterHitRate: Double { hitRate(taps.filter(\.isCluster)) }

    var extraContacts: Int? {
        doubleTaps.map { $0.reduce(0) { $0 + max(0, $1.contacts - 2) } }
    }

    var meanHoldMovement: Double? { holds.map { $0.map(\.movement).mean } }

    /// The keyboard the profile suggests, before the user changes anything.
    func proposedSettings() -> KeyboardSettings {
        var settings = KeyboardSettings()
        settings.keySize = (clusterHitRate < 0.8 || singleHitRate < 0.9) ? .large : .standard
        let offset = meanOffset
        settings.offsetEnabled = hypot(offset.dx, offset.dy) > 3
        settings.offsetX = offset.dx
        settings.offsetY = offset.dy
        settings.repeatFilterEnabled = (extraContacts ?? 1) > 0
        settings.toleranceEnabled = true
        settings.tolerance = max(12, ((meanHoldMovement ?? 6) * 1.6).rounded())
        settings.correctionBarEnabled = true
        return settings
    }

    var findings: [Finding] {
        var findings: [Finding] = []
        if !taps.isEmpty {
            let offset = meanOffset
            if let direction = directionText(offset) {
                findings.append(Finding(
                    text: "Your touches often land slightly \(direction).",
                    detail: "On average \(abs(offset.dx).points) \(offset.dx >= 0 ? "right" : "left") and \(abs(offset.dy).points) \(offset.dy >= 0 ? "below" : "above") the centre of the target."))
            } else {
                findings.append(Finding(text: "Your touches land close to the centre of targets.",
                                        detail: "No consistent direction of offset."))
            }
            if clusterHitRate < singleHitRate - 0.1 {
                findings.append(Finding(
                    text: "Closely spaced targets were harder to select.",
                    detail: "\(clusterHitRate.percent) of close targets hit, versus \(singleHitRate.percent) of separate ones."))
            } else {
                findings.append(Finding(
                    text: "Close and separate targets went about equally well.",
                    detail: "\(clusterHitRate.percent) and \(singleHitRate.percent) hit."))
            }
        }
        if let doubleTaps, let extra = extraContacts {
            findings.append(extra > 0
                ? Finding(text: "Some taps produced several separate contacts.",
                          detail: "\(extra) extra contact\(extra == 1 ? "" : "s") across \(doubleTaps.count) double-tap rounds.")
                : Finding(text: "Each tap registered as one contact.",
                          detail: "No extra contacts across \(doubleTaps.count) rounds."))
        }
        if let holds, let movement = meanHoldMovement {
            findings.append(Finding(
                text: "Your finger moved about \(movement.points) while touching.",
                detail: "Each touch lasted about \(String(format: "%.2f", holds.map(\.duration).mean)) s."))
        }
        if let pathDeviation {
            findings.append(Finding(text: "Sliding stayed within about \(pathDeviation.points) of the path.",
                                    detail: "Measured along the whole slide."))
        }
        if let phrase {
            findings.append(Finding(
                text: "Copying the phrase took \(phrase.corrections) correction\(phrase.corrections == 1 ? "" : "s").",
                detail: "\(phrase.errors) difference\(phrase.errors == 1 ? "" : "s") remained at the end."))
        }
        return findings.isEmpty
            ? [Finding(text: "Not enough to go on yet.",
                       detail: "All exercises were skipped — standard settings will be proposed.")]
            : findings
    }

    private func hitRate(_ samples: [TapSample]) -> Double {
        samples.isEmpty ? 1 : Double(samples.filter(\.hit).count) / Double(samples.count)
    }
}

extension TouchProfile {
    /// A plausible profile for exploring the app before doing the exercises:
    /// touches land low and to the right, close targets are harder, some taps bounce.
    static let sample = TouchProfile(
        hand: .right,
        taps: [
            (false, 9.1, 4.2, true), (true, 4.3, -1.8, true), (false, 11.6, 6.9, true), (true, 14.2, 1.1, false),
            (false, 6.0, 8.3, true), (true, 3.1, 3.5, true), (false, 8.8, -2.4, true), (true, 16.5, 5.0, false),
            (false, 5.2, 0.6, true), (true, 7.7, 4.9, true),
        ].map { TapSample(isCluster: $0.0, dx: $0.1, dy: $0.2, hit: $0.3) },
        doubleTaps: [.init(interval: 0.31, contacts: 2), .init(interval: 0.28, contacts: 3),
                     .init(interval: 0.35, contacts: 2), .init(interval: 0.30, contacts: 3)],
        holds: [.init(duration: 0.41, movement: 7), .init(duration: 0.38, movement: 9),
                .init(duration: 0.52, movement: 6), .init(duration: 0.44, movement: 8)],
        pathDeviation: 8.6,
        phrase: PhraseResult(errors: 3, corrections: 5, time: 24))
}

/// "low and to the right", "high", … or nil when the offset is negligible.
func directionText(_ offset: CGVector) -> String? {
    let horizontal = offset.dx > 3 ? "to the right" : offset.dx < -3 ? "to the left" : ""
    let vertical = offset.dy > 3 ? "low" : offset.dy < -3 ? "high" : ""
    switch (horizontal.isEmpty, vertical.isEmpty) {
    case (true, true): return nil
    case (false, false): return "\(vertical) and \(horizontal)"
    default: return horizontal.isEmpty ? vertical : horizontal
    }
}

extension Array where Element == Double {
    var mean: Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}

extension Array where Element == TapSample {
    var meanOffset: CGVector { CGVector(dx: map(\.dx).mean, dy: map(\.dy).mean) }
}

extension Double {
    var points: String { "\(Int(rounded())) pt" }
    var percent: String { "\(Int((self * 100).rounded()))%" }
}

extension CGFloat {
    var points: String { Double(self).points }
}

/// Edit distance, used to count the differences left in a typed phrase.
func levenshtein(_ a: String, _ b: String) -> Int {
    let a = Array(a), b = Array(b)
    guard !a.isEmpty else { return b.count }
    guard !b.isEmpty else { return a.count }
    var previous = Array(0...b.count)
    for i in 1...a.count {
        var current = [i] + Array(repeating: 0, count: b.count)
        for j in 1...b.count {
            current[j] = Swift.min(previous[j] + 1, current[j - 1] + 1,
                                   previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1))
        }
        previous = current
    }
    return previous[b.count]
}
