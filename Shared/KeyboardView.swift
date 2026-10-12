import SwiftUI

enum CorrectionAction {
    case undo, deleteWord, backspace
}

enum ShiftState {
    case off
    /// Capitalises the next letter only.
    case once
    case capsLock
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
    var options = KeyboardLayout.Options()
    var showsCorrectionBar = false
    var shift: ShiftState = .off
    var simulation: TouchSimulation?
    var onPress: (KeyPress) -> Void = { _ in }
    var onBlockedRepeat: () -> Void = {}
    var onCorrection: (CorrectionAction) -> Void = { _ in }
    /// Called repeatedly while delete is held down; nil turns hold-to-repeat off.
    var onRepeatDelete: (() -> Void)?

    @State private var interpreter = KeyTouchInterpreter()
    @State private var pressed: [AnyHashable: String] = [:]
    @State private var displacements: [AnyHashable: CGVector] = [:]
    @State private var repeatTasks: [AnyHashable: Task<Void, Never>] = [:]
    /// Touches that already deleted by repeating, so lifting them types nothing more.
    @State private var repeated: Set<AnyHashable> = []

    /// Hold this long before delete starts repeating, then repeat at this interval.
    /// The delay is longer than usual so a slow release doesn't erase text.
    static let repeatDelay: Duration = .milliseconds(800)
    static let repeatInterval: Duration = .milliseconds(110)

    var body: some View {
        VStack(spacing: options.compact ? 4 : 8) {
            if showsCorrectionBar {
                CorrectionBar(compact: options.compact, onCorrection: onCorrection)
            }
            GeometryReader { geo in
                let layout = KeyboardLayout(size: size, width: geo.size.width, options: options)
                ZStack {
                    ForEach(layout.keys) { key in
                        KeyCap(key: key, isPressed: pressed.values.contains(key.id), shift: shift)
                            .frame(width: key.frame.width, height: key.frame.height)
                            .position(x: key.frame.midX, y: key.frame.midY)
                            .accessibilityAction {
                                onPress(KeyPress(key: key, uncorrectedKey: key))
                            }
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
            .frame(height: size.keyboardHeight(compact: options.compact))
        }
        .onDisappear {
            repeatTasks.values.forEach { $0.cancel() }
            repeatTasks = [:]
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
                let key = interpreter.currentKey(id, layout: layout, behavior: behavior)
                pressed[id] = key?.id
                updateRepeat(id, onDelete: key?.action == .backspace)
            case .ended:
                guard interpreter.isTracking(id) else { continue }
                let point = simulated(event.location, id)
                finish(id)
                if repeated.remove(id) != nil {
                    interpreter.cancel(id)
                    continue
                }
                deliver(interpreter.ended(id, at: point, time: now, layout: layout, behavior: behavior))
                if let simulation, Double.random(in: 0..<1) < simulation.extraContactChance {
                    let ghost = AnyHashable(UUID())
                    interpreter.began(ghost, at: point, time: now + 0.035)
                    deliver(interpreter.ended(ghost, at: point, time: now + 0.07, layout: layout, behavior: behavior))
                }
            case .cancelled:
                interpreter.cancel(id)
                finish(id)
                repeated.remove(id)
            @unknown default:
                break
            }
        }
    }

    private func finish(_ id: AnyHashable) {
        pressed[id] = nil
        displacements[id] = nil
        repeatTasks.removeValue(forKey: id)?.cancel()
    }

    /// Starts repeating once a touch has rested on delete long enough; stops if it slides off.
    private func updateRepeat(_ id: AnyHashable, onDelete: Bool) {
        guard let onRepeatDelete, onDelete else {
            repeatTasks.removeValue(forKey: id)?.cancel()
            return
        }
        guard repeatTasks[id] == nil else { return }
        repeatTasks[id] = Task {
            try? await Task.sleep(for: Self.repeatDelay)
            while !Task.isCancelled {
                repeated.insert(id)
                onRepeatDelete()
                try? await Task.sleep(for: Self.repeatInterval)
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
    let shift: ShiftState

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadius)
            .fill(isPressed ? Theme.accent300 : (key.isInput ? Theme.bg : Theme.neutral300))
            .shadow(color: .black.opacity(0.18), radius: 0, x: 0, y: 1)
            .overlay { label }
            .foregroundStyle(Theme.text)
            .accessibilityElement()
            .accessibilityLabel(accessibilityName)
            .accessibilityValue(key.action == .shift ? shiftDescription : "")
            .accessibilityAddTraits(.isKeyboardKey)
    }

    private var isUppercase: Bool { shift != .off && key.isLetter }

    @ViewBuilder private var label: some View {
        switch key.action {
        case .backspace: Image(systemName: "delete.left").font(.system(size: 18))
        case .shift:
            Image(systemName: shift == .capsLock ? "capslock.fill" : shift == .once ? "shift.fill" : "shift")
                .font(.system(size: 18))
        case .nextKeyboard: Image(systemName: "globe").font(.system(size: 18))
        case .space, .returnKey, .mode:
            Text(key.label)
                .font(Theme.serif(size: 14))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 2)
        case .character:
            Text(isUppercase ? key.label.uppercased() : key.label)
                .font(Theme.serif(size: 20))
        }
    }

    private var shiftDescription: String {
        switch shift {
        case .off: "Off"
        case .once: "On"
        case .capsLock: "Caps lock"
        }
    }

    private var accessibilityName: String {
        switch key.action {
        case .backspace: "Delete"
        case .shift: "Shift"
        case .nextKeyboard: "Next keyboard"
        case .returnKey: key.label.capitalized
        case .space: "Space"
        case .mode(.letters): "Letters"
        case .mode(.numbers): "Numbers"
        case .mode(.symbols): "More symbols"
        case .mode(.numberPad): "Number pad"
        case .character(let c):
            switch c {
            case ",": "Comma"
            case ".": "Period"
            case "'": "Apostrophe"
            case "\"": "Quote"
            case "-": "Hyphen"
            case "/": "Slash"
            case "@": "At"
            default: isUppercase ? c.uppercased() : c
            }
        }
    }
}

private struct CorrectionBar: View {
    var compact = false
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
                .frame(maxWidth: .infinity, minHeight: compact ? 34 : 48)
                .background(Theme.bg, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.divider))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.text)
        .accessibilityLabel(action == .backspace ? "Backspace" : title)
    }
}
