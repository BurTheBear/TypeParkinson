import Foundation

/// The kind of touch pattern the exercises and practice show. Describes how
/// touches behave so the keyboard can adapt; it isn't a diagnosis and says
/// nothing about any condition or its type.
enum TouchPattern: String, Codable, CaseIterable, Identifiable {
    case steady
    /// Touches shake around the target and sometimes land twice.
    case tremor
    /// Accurate but slow to start and to lift; the finger drifts while held.
    case slowness
    /// Touches sometimes jump well away from the target, in no fixed direction.
    case suddenMovements
    /// No single pattern stands out.
    case mixed

    var id: String { rawValue }

    var name: String {
        switch self {
        case .steady: "Steady"
        case .tremor: "Shaky touches"
        case .slowness: "Slow, drifting touches"
        case .suddenMovements: "Sudden jumps"
        case .mixed: "Mixed"
        }
    }

    var symbol: String {
        switch self {
        case .steady: "hand.raised"
        case .tremor: "waveform.path"
        case .slowness: "tortoise"
        case .suddenMovements: "bolt"
        case .mixed: "circle.hexagongrid"
        }
    }

    var explanation: String {
        switch self {
        case .steady: "Your touches are precise and even."
        case .tremor: "Touches shake around the target and sometimes register twice."
        case .slowness: "Touches are accurate but slow to start and lift, and your finger drifts while it rests."
        case .suddenMovements: "Now and then a touch lands well away from where you aimed, in no fixed direction."
        case .mixed: "A bit of several patterns, with none standing out."
        }
    }

    /// What the keyboard does about it, in plain words.
    var adaptations: [String] {
        switch self {
        case .steady:
            ["Standard key sizes", "Light smart correction"]
        case .tremor:
            ["Ignores the quick second contact of a shaky tap", "Ignores brief brushes", "Wider smart correction around each key"]
        case .slowness:
            ["Keeps the key you first touched while your finger drifts", "Word suggestions to save key presses", "A slower hold-to-delete"]
        case .suddenMovements:
            ["Extra-large keys", "Strong smart correction for far-off touches", "Ignores brief brushes"]
        case .mixed:
            ["Large keys", "Repeat and drift handling", "Smart correction"]
        }
    }

    /// How much wider the keyboard's touch model starts than the exercises measured.
    var spreadFactor: Double {
        switch self {
        case .steady: 1
        case .tremor: 1.25
        case .slowness: 1
        case .suddenMovements: 1.5
        case .mixed: 1.2
        }
    }

    static let classified: [TouchPattern] = [.steady, .tremor, .slowness, .suddenMovements]
}

/// The classifier's output: a probability per pattern and the one it settled on.
struct TouchPatternEstimate: Codable, Equatable {
    /// Keyed by `TouchPattern.rawValue`.
    var probabilities: [String: Double]
    var primary: TouchPattern
    /// How many measurements it was based on.
    var evidence: Int

    func probability(_ pattern: TouchPattern) -> Double {
        probabilities[pattern.rawValue] ?? 0
    }
}
