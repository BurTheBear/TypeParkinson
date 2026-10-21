import SwiftUI
#if canImport(UIKit)
import UIKit

/// One finger's touch, straight from UIKit.
struct FingerEvent {
    enum Phase { case began, moved, ended, cancelled }

    let id: ObjectIdentifier
    let location: CGPoint
    /// The touch's own hardware timestamp (system uptime), not when the app got round to it.
    let time: TimeInterval
    let phase: Phase
}

/// A transparent view that reports every finger separately, with UIKit's
/// timestamps. SwiftUI gestures can merge or drop very short touches; a
/// keyboard for shaky hands needs every contact, and its real timing, to tell
/// a bounce from a deliberate tap.
struct MultiTouchSurface: UIViewRepresentable {
    var onEvent: (FingerEvent) -> Void

    func makeUIView(context: Context) -> TouchView {
        let view = TouchView()
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        view.onEvent = onEvent
        return view
    }

    func updateUIView(_ view: TouchView, context: Context) {
        view.onEvent = onEvent
    }

    final class TouchView: UIView {
        var onEvent: (FingerEvent) -> Void = { _ in }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            report(touches, .began)
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            report(touches, .moved)
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            report(touches, .ended)
        }

        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            report(touches, .cancelled)
        }

        private func report(_ touches: Set<UITouch>, _ phase: FingerEvent.Phase) {
            for touch in touches.sorted(by: { $0.timestamp < $1.timestamp }) {
                onEvent(FingerEvent(id: ObjectIdentifier(touch), location: touch.location(in: self),
                                    time: touch.timestamp, phase: phase))
            }
        }
    }
}
#endif
