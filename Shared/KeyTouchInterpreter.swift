import CoreGraphics
import Foundation

/// How touches are turned into key presses.
struct KeyboardBehavior: Equatable {
    /// Subtracted from each touch, so a touch that habitually lands low-right reads as aimed.
    var offset: CGVector = .zero
    /// A second contact on the same key this soon after the previous one lifted is ignored.
    var repeatWindow: TimeInterval?
    /// Drift (in points) allowed before lifting while still keeping the key first touched.
    var tolerance: CGFloat?

    static let standard = KeyboardBehavior()
}

struct KeyPress {
    let key: Key
    /// What the touch would have selected without the offset correction.
    let uncorrectedKey: Key?
}

/// Tracks individual touches (several can be down at once) and decides which
/// key, if any, each one presses when it lifts.
final class KeyTouchInterpreter {
    enum Outcome {
        case press(KeyPress)
        case blockedRepeat
        case none
    }

    private struct Touch {
        var down: CGPoint
        var last: CGPoint
        var downTime: TimeInterval
        var maxMove: CGFloat = 0
    }

    private var touches: [AnyHashable: Touch] = [:]
    private var lastPress: (keyID: String, upTime: TimeInterval)?

    func isTracking(_ id: AnyHashable) -> Bool { touches[id] != nil }

    func began(_ id: AnyHashable, at point: CGPoint, time: TimeInterval) {
        touches[id] = Touch(down: point, last: point, downTime: time)
    }

    func moved(_ id: AnyHashable, to point: CGPoint) {
        guard var touch = touches[id] else { return }
        touch.last = point
        touch.maxMove = max(touch.maxMove, hypot(point.x - touch.down.x, point.y - touch.down.y))
        touches[id] = touch
    }

    func cancel(_ id: AnyHashable) {
        touches[id] = nil
    }

    /// The key that would be pressed if this touch lifted now, for highlighting.
    func currentKey(_ id: AnyHashable, layout: KeyboardLayout, behavior: KeyboardBehavior) -> Key? {
        guard let touch = touches[id] else { return nil }
        return layout.key(at: aimed(touch, behavior: behavior).corrected)
    }

    func ended(_ id: AnyHashable, at point: CGPoint, time: TimeInterval,
               layout: KeyboardLayout, behavior: KeyboardBehavior) -> Outcome {
        moved(id, to: point)
        guard let touch = touches.removeValue(forKey: id) else { return .none }
        let aim = aimed(touch, behavior: behavior)
        guard let key = layout.key(at: aim.corrected) else { return .none }

        if let window = behavior.repeatWindow, let last = lastPress,
           last.keyID == key.id, touch.downTime - last.upTime < window {
            lastPress = (key.id, time)
            return .blockedRepeat
        }
        lastPress = (key.id, time)
        return .press(KeyPress(key: key, uncorrectedKey: layout.key(at: aim.raw)))
    }

    private func aimed(_ touch: Touch, behavior: KeyboardBehavior) -> (raw: CGPoint, corrected: CGPoint) {
        let withinTolerance = behavior.tolerance.map { touch.maxMove <= $0 } ?? false
        let raw = withinTolerance ? touch.down : touch.last
        return (raw, CGPoint(x: raw.x - behavior.offset.dx, y: raw.y - behavior.offset.dy))
    }
}
