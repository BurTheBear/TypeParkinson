import SwiftUI

enum CorrectionAction {
    case undo, deleteWord, backspace
}

/// Simulated imprecision for demos on the simulator, where a mouse is too precise.
struct TouchSimulation {
    /// A fixed displacement applied to the whole of one touch.
    var displacement: () -> CGVector
    /// Chance that a press is followed by an accidental second contact.
    var extraContactChance: Double
}

/// The TypeParkinson keyboard. Used for the in-app typing tasks and inside the
/// keyboard extension. Handles each finger separately, so accidental extra
/// contacts reach the interpreter instead of being merged into one gesture.
struct KeyboardView: View {
    var size: KeySize
    var behavior: KeyboardBehavior = .standard
    var systemKeys = false
    var showsCorrectionBar = false
    var isShifted = false
    var simulation: TouchSimulation?
    var onPress: (KeyPress) -> Void = { _ in }
    var onBlockedRepeat: () -> Void = {}
    var onCorrection: (CorrectionAction) -> Void = { _ in }

    @State private var interpreter = KeyTouchInterpreter()
    @State private var pressed: [AnyHashable: String] = [:]
    @State private var displacements: [AnyHashable: CGVector] = [:]

    var body: some View {
        VStack(spacing: 8) {
            if showsCorrectionBar {
                CorrectionBar(onCorrection: onCorrection)
            }
            GeometryReader { geo in
                let layout = KeyboardLayout(size: size, width: geo.size.width, systemKeys: systemKeys)
                ZStack {
                    ForEach(layout.keys) { key in
                        KeyCap(key: key, isPressed: pressed.values.contains(key.id), isShifted: isShifted)
                            .frame(width: key.frame.width, height: key.frame.height)
                            .position(x: key.frame.midX, y: key.frame.midY)
                    }
                }
                .frame(width: geo.size.width, height: layout.height)
                .contentShape(Rectangle())
                .gesture(
                    SpatialEventGesture(coordinateSpace: .local)
                        .onChanged { handle($0, layout: layout) }
                        .onEnded { handle($0, layout: layout) }
                )
                .accessibilityElement(children: .contain)
            }
            .frame(height: size.keyboardHeight)
        }
    }

    private func handle(_ events: SpatialEventCollection, layout: KeyboardLayout) {
        let now = ProcessInfo.processInfo.systemUptime
        for event in events {
            let id = AnyHashable(event.id)
            switch event.phase {
            case .active:
                if interpreter.isTracking(id) {
                    interpreter.moved(id, to: simulated(event.location, id))
                } else {
                    if let simulation { displacements[id] = simulation.displacement() }
                    interpreter.began(id, at: simulated(event.location, id), time: now)
                }
                pressed[id] = interpreter.currentKey(id, layout: layout, behavior: behavior)?.id
            case .ended:
                guard interpreter.isTracking(id) else { continue }
                let point = simulated(event.location, id)
                pressed[id] = nil
                displacements[id] = nil
                deliver(interpreter.ended(id, at: point, time: now, layout: layout, behavior: behavior))
                if let simulation, Double.random(in: 0..<1) < simulation.extraContactChance {
                    let ghost = AnyHashable(UUID())
                    interpreter.began(ghost, at: point, time: now + 0.035)
                    deliver(interpreter.ended(ghost, at: point, time: now + 0.07, layout: layout, behavior: behavior))
                }
            case .cancelled:
                interpreter.cancel(id)
                pressed[id] = nil
                displacements[id] = nil
            @unknown default:
                break
            }
        }
    }

    private func simulated(_ point: CGPoint, _ id: AnyHashable) -> CGPoint {
        guard let d = displacements[id] else { return point }
        return CGPoint(x: point.x + d.dx, y: point.y + d.dy)
    }

    private func deliver(_ outcome: KeyTouchInterpreter.Outcome) {
        switch outcome {
        case .press(let press): onPress(press)
        case .blockedRepeat: onBlockedRepeat()
        case .none: break
        }
    }
}

private struct KeyCap: View {
    let key: Key
    let isPressed: Bool
    let isShifted: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadius)
            .fill(isPressed ? Theme.accent300 : (key.isLetter ? Theme.bg : Theme.neutral300))
            .shadow(color: .black.opacity(0.18), radius: 0, x: 0, y: 1)
            .overlay { label }
            .foregroundStyle(Theme.text)
            .accessibilityElement()
            .accessibilityLabel(accessibilityName)
            .accessibilityAddTraits(.isKeyboardKey)
    }

    @ViewBuilder private var label: some View {
        switch key.action {
        case .backspace: Image(systemName: "delete.left").font(.system(size: 18))
        case .shift: Image(systemName: isShifted ? "shift.fill" : "shift").font(.system(size: 18))
        case .nextKeyboard: Image(systemName: "globe").font(.system(size: 18))
        case .space, .returnKey: Text(key.label).font(Theme.serif(size: 14))
        case .character:
            Text(isShifted && key.isLetter ? key.label.uppercased() : key.label)
                .font(Theme.serif(size: 20))
        }
    }

    private var accessibilityName: String {
        switch key.action {
        case .backspace: "Delete"
        case .shift: "Shift"
        case .nextKeyboard: "Next keyboard"
        case .returnKey: "Return"
        case .space: "Space"
        case .character(let c): c == "," ? "Comma" : c == "." ? "Period" : c
        }
    }
}

private struct CorrectionBar: View {
    let onCorrection: (CorrectionAction) -> Void

    var body: some View {
        HStack(spacing: 8) {
            button("Undo", .undo)
            button("Delete word", .deleteWord)
            button("⌫ Backspace", .backspace)
        }
    }

    private func button(_ title: String, _ action: CorrectionAction) -> some View {
        Button { onCorrection(action) } label: {
            Text(title)
                .font(Theme.serif(size: 15, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Theme.bg, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.divider))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.text)
    }
}
