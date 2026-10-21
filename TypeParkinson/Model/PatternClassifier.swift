import Foundation

/// Estimates the person's touch pattern from what the exercises and practice
/// measured, with a Gaussian naive Bayes classifier that runs on the device.
///
/// Each pattern is described by the typical value and spread of each
/// measurement (how scattered taps are, extra contacts, finger drift while
/// holding, how long holds last, how far a slide strays, typing speed, spiral
/// smoothness, tapping speed and rhythm). Those parameters are set from what's
/// described in motor-symptom research rather than trained on patient data,
/// which TypeParkinson doesn't have. Every measurement that's missing is simply
/// left out, so a skipped exercise lowers confidence instead of skewing it.
enum PatternClassifier {
    struct Features: Equatable {
        /// Root-mean-square spread of taps around their own average, in points.
        var scatter: Double?
        /// Extra contacts per double-tap round.
        var extraContacts: Double?
        /// How far the finger moved while resting on a target, in points.
        var holdMovement: Double?
        /// How long a touch-and-release lasted, in seconds.
        var holdDuration: Double?
        /// How far a slide strayed from the path, in points.
        var pathDeviation: Double?
        /// Characters per second while copying a phrase.
        var typingRate: Double?
        /// Spiral smoothness, 0 to 1.
        var spiralSmoothness: Double?
        /// Taps in ten seconds of rhythm tapping.
        var tappingRate: Double?
        /// Evenness of the tapping rhythm, 0 to 1.
        var rhythm: Double?

        var values: [Feature: Double] {
            var v: [Feature: Double] = [:]
            v[.scatter] = scatter
            v[.extraContacts] = extraContacts
            v[.holdMovement] = holdMovement
            v[.holdDuration] = holdDuration
            v[.pathDeviation] = pathDeviation
            v[.typingRate] = typingRate
            v[.spiralSmoothness] = spiralSmoothness
            v[.tappingRate] = tappingRate
            v[.rhythm] = rhythm
            return v
        }
    }

    enum Feature: CaseIterable {
        case scatter, extraContacts, holdMovement, holdDuration, pathDeviation
        case typingRate, spiralSmoothness, tappingRate, rhythm
    }

    /// (mean, standard deviation) of each measurement for each pattern.
    static let parameters: [TouchPattern: [Feature: (mean: Double, sd: Double)]] = [
        .steady: [
            .scatter: (3.5, 1.8), .extraContacts: (0.05, 0.25), .holdMovement: (2.5, 1.5), .holdDuration: (0.35, 0.15),
            .pathDeviation: (3.5, 2), .typingRate: (2.6, 0.9), .spiralSmoothness: (0.93, 0.04), .tappingRate: (50, 10), .rhythm: (0.85, 0.07),
        ],
        .tremor: [
            .scatter: (8, 3), .extraContacts: (0.9, 0.6), .holdMovement: (8, 3), .holdDuration: (0.4, 0.2),
            .pathDeviation: (9, 3.5), .typingRate: (1.6, 0.7), .spiralSmoothness: (0.72, 0.09), .tappingRate: (40, 10), .rhythm: (0.7, 0.1),
        ],
        .slowness: [
            .scatter: (4.5, 2), .extraContacts: (0.15, 0.3), .holdMovement: (4, 2), .holdDuration: (0.8, 0.3),
            .pathDeviation: (6, 3), .typingRate: (0.8, 0.4), .spiralSmoothness: (0.88, 0.06), .tappingRate: (25, 8), .rhythm: (0.6, 0.12),
        ],
        .suddenMovements: [
            .scatter: (13, 5), .extraContacts: (0.5, 0.5), .holdMovement: (11, 5), .holdDuration: (0.45, 0.25),
            .pathDeviation: (14, 6), .typingRate: (1.3, 0.7), .spiralSmoothness: (0.75, 0.1), .tappingRate: (38, 12), .rhythm: (0.5, 0.15),
        ],
    ]

    /// Below this, no single pattern is confident enough and the result is "mixed".
    static let confidenceThreshold = 0.5

    static func classify(_ features: Features) -> TouchPatternEstimate {
        let values = features.values
        guard !values.isEmpty else {
            let even = 1 / Double(TouchPattern.classified.count)
            return TouchPatternEstimate(probabilities: Dictionary(uniqueKeysWithValues: TouchPattern.classified.map { ($0.rawValue, even) }),
                                        primary: .mixed, evidence: 0)
        }
        // Summed log-likelihoods are tempered by √n: the measurements aren't truly
        // independent, and naive Bayes is otherwise far too sure of itself.
        let temperature = sqrt(Double(values.count))
        var scores: [TouchPattern: Double] = [:]
        for pattern in TouchPattern.classified {
            let params = parameters[pattern] ?? [:]
            var total = 0.0
            for (feature, value) in values {
                guard let p = params[feature] else { continue }
                let z = (value - p.mean) / p.sd
                total += -0.5 * z * z - log(p.sd)
            }
            scores[pattern] = total / temperature
        }
        let maxScore = scores.values.max() ?? 0
        let exp = scores.mapValues { Foundation.exp($0 - maxScore) }
        let sum = exp.values.reduce(0, +)
        let probabilities = exp.mapValues { $0 / sum }
        let top = probabilities.max { $0.value < $1.value }
        let primary = (top?.value ?? 0) >= confidenceThreshold ? (top?.key ?? .mixed) : .mixed
        return TouchPatternEstimate(probabilities: Dictionary(uniqueKeysWithValues: probabilities.map { ($0.key.rawValue, $0.value) }),
                                    primary: primary, evidence: values.count)
    }

    /// The measurements available from the setup exercises and recent practice.
    static func features(profile: TouchProfile, log: ActivityLog? = nil) -> Features {
        var f = Features()
        if profile.taps.count >= 3 {
            let mean = profile.taps.meanOffset
            f.scatter = sqrt(profile.taps.map { pow($0.dx - mean.dx, 2) + pow($0.dy - mean.dy, 2) }.mean)
        }
        if let doubleTaps = profile.doubleTaps, !doubleTaps.isEmpty, let extra = profile.extraContacts {
            f.extraContacts = Double(extra) / Double(doubleTaps.count)
        }
        if let holds = profile.holds, !holds.isEmpty {
            f.holdMovement = holds.map(\.movement).mean
            f.holdDuration = holds.map(\.duration).mean
        }
        f.pathDeviation = profile.pathDeviation
        if let phrase = profile.phrase, phrase.time > 1 {
            f.typingRate = Double(Phrases.exercise.count) / phrase.time
        }
        if let log {
            let recentSpirals = log.spirals.suffix(3)
            if !recentSpirals.isEmpty { f.spiralSmoothness = recentSpirals.map(\.result.smoothness).mean }
            let recentTapping = log.tapping.suffix(3)
            if !recentTapping.isEmpty {
                f.tappingRate = recentTapping.map(\.result.tapsPerTenSeconds).mean
                f.rhythm = recentTapping.map(\.result.consistency).mean
            }
        }
        return f
    }
}
