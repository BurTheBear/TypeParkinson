import CoreGraphics
import Foundation

/// The personalised keyboard. Written by the app, read by the keyboard extension.
struct KeyboardSettings: Codable, Equatable {
    var keySize: KeySize = .standard
    /// Shift each touch by the user's average offset before picking a key.
    var offsetEnabled = false
    var offsetX: Double = 0
    var offsetY: Double = 0
    /// Ignore a second contact on the same key within `repeatWindow`.
    var repeatFilterEnabled = false
    /// Keep the key first touched if the finger drifts up to `tolerance` points before lifting.
    var toleranceEnabled = true
    var tolerance: Double = 12
    /// Large Undo / Delete word / Backspace buttons above the keys.
    var correctionBarEnabled = true
    /// Holding delete keeps deleting, after a longer pause than the standard keyboard.
    var holdToDeleteEnabled = true
    /// A same-day override from "Typing feels different today".
    var todayOffset: TodayOffset?

    // Added after the first release; older saved settings load with these defaults.

    /// Ignore touches that lift sooner than `brushDuration`: a finger brushing past a key.
    var brushFilterEnabled = false
    var brushDuration: Double = 0.04
    /// Three word completions above the keys.
    var suggestionsEnabled = true
    /// A button above the keys that opens the person's saved phrases.
    var phrasesEnabled = true
    /// A larger copy of the key appears above the finger while it's down.
    var keyPreviewEnabled = true
    var theme: KeyboardTheme = .classic
    var largeLabels = false
    /// Decode each finished word from where the touches landed (`IntentDecoder`)
    /// and fix it when confident. Undo puts back exactly what was typed.
    var smartCorrectionEnabled = true
    /// Where this person's touches land around a key, from the exercises.
    var touchModel: TouchModel?
    /// The touch pattern the exercises showed, which tunes how strongly smart correction acts.
    var pattern: TouchPattern?

    init() {}

    /// The decoder settings the keyboard should use.
    var correctionStrength: Double { pattern?.correctionStrength ?? 0.6 }

    static let repeatWindow: TimeInterval = 0.12
    static let brushDurations: [Double] = [0.03, 0.04, 0.06, 0.08]

    struct TodayOffset: Codable, Equatable {
        var x: Double
        var y: Double
        var date: Date

        var isCurrent: Bool { Calendar.current.isDateInToday(date) }
    }

    /// The offset to use now: today's, if one was set today, otherwise the usual one.
    var currentOffset: CGVector {
        if let today = todayOffset, today.isCurrent {
            return CGVector(dx: today.x, dy: today.y)
        }
        return CGVector(dx: offsetX, dy: offsetY)
    }

    /// Today's override applies even when the usual offset correction is off.
    var behavior: KeyboardBehavior {
        KeyboardBehavior(
            offset: (offsetEnabled || todayOffset?.isCurrent == true) ? currentOffset : .zero,
            repeatWindow: repeatFilterEnabled ? Self.repeatWindow : nil,
            tolerance: toleranceEnabled ? CGFloat(tolerance) : nil,
            minimumPress: brushFilterEnabled ? brushDuration : nil
        )
    }
}

extension KeyboardSettings {
    private enum CodingKeys: String, CodingKey {
        case keySize, offsetEnabled, offsetX, offsetY, repeatFilterEnabled
        case toleranceEnabled, tolerance, correctionBarEnabled, holdToDeleteEnabled, todayOffset
        case brushFilterEnabled, brushDuration, suggestionsEnabled, phrasesEnabled, keyPreviewEnabled
        case theme, largeLabels, smartCorrectionEnabled, touchModel, pattern
    }

    /// Missing fields keep their defaults, so settings saved by an older version
    /// (or synced from another device) still load.
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        keySize = try c.decodeIfPresent(KeySize.self, forKey: .keySize) ?? keySize
        offsetEnabled = try c.decodeIfPresent(Bool.self, forKey: .offsetEnabled) ?? offsetEnabled
        offsetX = try c.decodeIfPresent(Double.self, forKey: .offsetX) ?? offsetX
        offsetY = try c.decodeIfPresent(Double.self, forKey: .offsetY) ?? offsetY
        repeatFilterEnabled = try c.decodeIfPresent(Bool.self, forKey: .repeatFilterEnabled) ?? repeatFilterEnabled
        toleranceEnabled = try c.decodeIfPresent(Bool.self, forKey: .toleranceEnabled) ?? toleranceEnabled
        tolerance = try c.decodeIfPresent(Double.self, forKey: .tolerance) ?? tolerance
        correctionBarEnabled = try c.decodeIfPresent(Bool.self, forKey: .correctionBarEnabled) ?? correctionBarEnabled
        holdToDeleteEnabled = try c.decodeIfPresent(Bool.self, forKey: .holdToDeleteEnabled) ?? holdToDeleteEnabled
        todayOffset = try c.decodeIfPresent(TodayOffset.self, forKey: .todayOffset)
        brushFilterEnabled = try c.decodeIfPresent(Bool.self, forKey: .brushFilterEnabled) ?? brushFilterEnabled
        brushDuration = try c.decodeIfPresent(Double.self, forKey: .brushDuration) ?? brushDuration
        suggestionsEnabled = try c.decodeIfPresent(Bool.self, forKey: .suggestionsEnabled) ?? suggestionsEnabled
        phrasesEnabled = try c.decodeIfPresent(Bool.self, forKey: .phrasesEnabled) ?? phrasesEnabled
        keyPreviewEnabled = try c.decodeIfPresent(Bool.self, forKey: .keyPreviewEnabled) ?? keyPreviewEnabled
        // An unknown theme from a newer version falls back to classic rather than failing the whole decode.
        theme = (try? c.decodeIfPresent(KeyboardTheme.self, forKey: .theme)) ?? theme
        largeLabels = try c.decodeIfPresent(Bool.self, forKey: .largeLabels) ?? largeLabels
        smartCorrectionEnabled = try c.decodeIfPresent(Bool.self, forKey: .smartCorrectionEnabled) ?? smartCorrectionEnabled
        touchModel = try? c.decodeIfPresent(TouchModel.self, forKey: .touchModel)
        pattern = try? c.decodeIfPresent(TouchPattern.self, forKey: .pattern)
    }
}

/// Shares settings between the app and the keyboard through an App Group.
/// The keyboard runs without Full Access, so it can read this but never write it.
/// Change `appGroup` (and both .entitlements files) if the bundle identifier changes.
enum SharedStore {
    static let appGroup = "group.com.pranavatreya.typeparkinson"
    private static let settingsKey = "keyboardSettings"
    private static let phrasesKey = "quickPhrases"

    static var defaults: UserDefaults { UserDefaults(suiteName: appGroup) ?? .standard }

    static func loadSettings() -> KeyboardSettings? {
        guard let data = defaults.data(forKey: settingsKey) else { return nil }
        return try? JSONDecoder().decode(KeyboardSettings.self, from: data)
    }

    static func save(_ settings: KeyboardSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }

    /// `nil` until the person has saved phrases; the keyboard then shows the starter set.
    static func loadPhrases() -> [QuickPhrase]? {
        guard let data = defaults.data(forKey: phrasesKey) else { return nil }
        return try? JSONDecoder().decode([QuickPhrase].self, from: data)
    }

    static func save(phrases: [QuickPhrase]) {
        guard let data = try? JSONEncoder().encode(phrases) else { return }
        defaults.set(data, forKey: phrasesKey)
    }

    static func clear() {
        defaults.removeObject(forKey: settingsKey)
        defaults.removeObject(forKey: phrasesKey)
    }
}
