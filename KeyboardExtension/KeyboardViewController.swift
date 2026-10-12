import SwiftUI
import UIKit

@Observable
final class KeyboardState {
    var settings: KeyboardSettings
    var shift: ShiftState = .off
    var mode: KeyboardMode = .letters
    var options = KeyboardLayout.Options(systemKeys: true)

    init(settings: KeyboardSettings) {
        self.settings = settings
    }

    /// Correction bar, keys and vertical padding.
    var height: CGFloat {
        let bar: CGFloat = settings.correctionBarEnabled ? (options.compact ? 38 : 56) : 0
        return 16 + bar + settings.keySize.keyboardHeight(compact: options.compact)
    }
}

/// The system keyboard. Reads the settings the app approved and types into
/// whatever app is in front. Nothing typed is stored or sent anywhere.
final class KeyboardViewController: UIInputViewController {
    private enum Edit {
        case inserted(String)
        case deleted(String)
    }

    private let state = KeyboardState(settings: SharedStore.loadSettings() ?? KeyboardSettings())
    private var undoStack: [Edit] = []
    /// Deletions from one hold of the delete key are undone together.
    private var isHoldingDelete = false
    private var heightConstraint: NSLayoutConstraint?
    private var lastKeyboardType: UIKeyboardType?

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = ExtensionKeyboardView(
            state: state,
            onPress: { [weak self] in self?.handle($0) },
            onCorrection: { [weak self] in self?.handle($0) },
            onRepeatDelete: { [weak self] in self?.repeatDelete() }
        )
        let host = UIHostingController(rootView: root)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(host)
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)

        let height = view.heightAnchor.constraint(equalToConstant: state.height)
        height.priority = .defaultHigh
        height.isActive = true
        heightConstraint = height

        registerForTraitChanges([UITraitVerticalSizeClass.self]) { (self: Self, _) in
            self.updateOptions()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Pick up changes made in the app (new settings, "adjust for today").
        if let settings = SharedStore.loadSettings() {
            state.settings = settings
        }
        updateOptions()
        updateAutoShift()
    }

    override func textDidChange(_ textInput: (any UITextInput)?) {
        super.textDidChange(textInput)
        updateOptions()
        updateAutoShift()
    }

    // MARK: Keys

    private func handle(_ press: KeyPress) {
        isHoldingDelete = false
        switch press.key.action {
        case .character(let c):
            insert(state.shift != .off ? c.uppercased() : c)
            if state.shift == .once { state.shift = .off }
            // Like the standard keyboard, an apostrophe goes back to letters.
            if c == "'", state.mode != .numberPad { state.mode = .letters }
        case .space:
            insert(" ")
            if state.mode == .numbers || state.mode == .symbols { state.mode = .letters }
        case .returnKey:
            insert("\n")
        case .backspace:
            deleteBackward(count: 1)
        case .shift:
            // One tap: next letter. Second tap: caps lock. Third: off.
            // Taps rather than a timed double tap, which is hard to do reliably.
            state.shift = switch state.shift {
            case .off: .once
            case .once: .capsLock
            case .capsLock: .off
            }
            return
        case .mode(let mode):
            state.mode = mode
            updateAutoShift()
            return
        case .nextKeyboard:
            advanceToNextInputMode()
            return
        }
        updateAutoShift()
    }

    private func repeatDelete() {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        guard let last = before.last else { return }
        textDocumentProxy.deleteBackward()
        if isHoldingDelete, case .deleted(let text)? = undoStack.last {
            undoStack[undoStack.count - 1] = .deleted(String(last) + text)
        } else {
            record(.deleted(String(last)))
        }
        isHoldingDelete = true
        updateAutoShift()
    }

    private func handle(_ action: CorrectionAction) {
        isHoldingDelete = false
        switch action {
        case .backspace:
            deleteBackward(count: 1)
        case .deleteWord:
            deleteBackward(count: trailingWordLength(textDocumentProxy.documentContextBeforeInput ?? ""))
        case .undo:
            guard let edit = undoStack.popLast() else { return }
            switch edit {
            case .inserted(let text):
                for _ in text { textDocumentProxy.deleteBackward() }
            case .deleted(let text):
                textDocumentProxy.insertText(text)
            }
        }
        updateAutoShift()
    }

    private func insert(_ text: String) {
        textDocumentProxy.insertText(text)
        record(.inserted(text))
    }

    private func deleteBackward(count: Int) {
        guard count > 0 else { return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        for _ in 0..<count { textDocumentProxy.deleteBackward() }
        let removed = String(before.suffix(count))
        if !removed.isEmpty { record(.deleted(removed)) }
    }

    private func record(_ edit: Edit) {
        undoStack.append(edit)
        if undoStack.count > 60 { undoStack.removeFirst() }
    }

    /// Length of the last word plus any spaces after it, or of trailing spaces alone.
    private func trailingWordLength(_ text: String) -> Int {
        let spaces = text.reversed().prefix { $0.isWhitespace }.count
        let word = text.dropLast(spaces).reversed().prefix { !$0.isWhitespace }.count
        return word + spaces
    }

    // MARK: Following the text field

    /// Matches the layout to the field being typed in and to the screen.
    private func updateOptions() {
        let proxy = textDocumentProxy
        let type = proxy.keyboardType ?? .default
        if type != lastKeyboardType {
            lastKeyboardType = type
            state.mode = switch type {
            case .numberPad, .asciiCapableNumberPad, .phonePad, .decimalPad: .numberPad
            case .numbersAndPunctuation: .numbers
            default: .letters
            }
        }

        var options = KeyboardLayout.Options(systemKeys: true)
        options.showsGlobe = needsInputModeSwitchKey
        options.returnLabel = Self.returnLabel(proxy.returnKeyType ?? .default)
        options.punctuation = switch type {
        case .emailAddress: "@"
        case .URL, .webSearch: "/"
        default: ","
        }
        options.numberPadExtra = switch type {
        case .decimalPad: Locale.current.decimalSeparator ?? "."
        case .phonePad: "+"
        default: nil
        }
        options.compact = traitCollection.verticalSizeClass == .compact
        if options != state.options {
            state.options = options
        }
        if heightConstraint?.constant != state.height {
            heightConstraint?.constant = state.height
        }
    }

    private static func returnLabel(_ type: UIReturnKeyType) -> String {
        switch type {
        case .go: "go"
        case .google, .yahoo, .search: "search"
        case .join: "join"
        case .next: "next"
        case .route: "route"
        case .send: "send"
        case .done: "done"
        case .emergencyCall: "call"
        case .continue: "continue"
        default: "return"
        }
    }

    private func updateAutoShift() {
        guard state.shift != .capsLock else { return }
        guard state.mode == .letters,
              textDocumentProxy.autocapitalizationType != UITextAutocapitalizationType.none else {
            state.shift = .off
            return
        }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let trimmed = before.trimmingCharacters(in: .whitespaces)
        let startsSentence = trimmed.isEmpty || before.hasSuffix("\n")
            || (before.hasSuffix(" ") && [".", "!", "?"].contains(trimmed.last))
        state.shift = startsSentence ? .once : .off
    }
}

private struct ExtensionKeyboardView: View {
    let state: KeyboardState
    let onPress: (KeyPress) -> Void
    let onCorrection: (CorrectionAction) -> Void
    let onRepeatDelete: () -> Void

    var body: some View {
        var options = state.options
        options.mode = state.mode
        return KeyboardView(
            size: state.settings.keySize,
            behavior: state.settings.behavior,
            options: options,
            showsCorrectionBar: state.settings.correctionBarEnabled,
            shift: state.shift,
            onPress: onPress,
            onCorrection: onCorrection,
            onRepeatDelete: state.settings.holdToDeleteEnabled ? onRepeatDelete : nil
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Theme.neutral200)
    }
}
