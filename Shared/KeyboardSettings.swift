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

    init() {}

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

extension KeyboardSettings {
    private enum CodingKeys: String, CodingKey {
        case keySize, offsetEnabled, offsetX, offsetY, repeatFilterEnabled
        case toleranceEnabled, tolerance, correctionBarEnabled, holdToDeleteEnabled, todayOffset
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
    }
}

/// Shares settings between the app and the keyboard through an App Group.
/// The keyboard runs without Full Access, so it can read this but never write it.
/// Change `appGroup` (and both .entitlements files) if the bundle identifier changes.
enum SharedStore {
    static let appGroup = "group.com.pranavatreya.typeparkinson"
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

    static func clear() {
        defaults.removeObject(forKey: settingsKey)
    }
}
