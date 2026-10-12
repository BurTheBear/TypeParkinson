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
    /// A same-day override from "Typing feels different today".
    var todayOffset: TodayOffset?

    static let repeatWindow: TimeInterval = 0.12

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
            tolerance: toleranceEnabled ? CGFloat(tolerance) : nil
        )
    }
}

/// Shares settings between the app and the keyboard through an App Group.
/// Change `appGroup` (and both .entitlements files) if the bundle identifier changes.
enum SharedStore {
    static let appGroup = "group.devplaceholder.J42KEV6W.TypeParkinson"
    private static let settingsKey = "keyboardSettings"

    static var defaults: UserDefaults { UserDefaults(suiteName: appGroup) ?? .standard }

    static func loadSettings() -> KeyboardSettings? {
        guard let data = defaults.data(forKey: settingsKey) else { return nil }
        return try? JSONDecoder().decode(KeyboardSettings.self, from: data)
    }

    static func save(_ settings: KeyboardSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }
}
