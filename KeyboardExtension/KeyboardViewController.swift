import SwiftUI
import UIKit

@Observable
final class KeyboardState {
    var settings: KeyboardSettings
    var isShifted = false

    init(settings: KeyboardSettings) {
        self.settings = settings
    }

    /// Correction bar, keys and vertical padding.
    var height: CGFloat {
        16 + (settings.correctionBarEnabled ? 56 : 0) + settings.keySize.keyboardHeight
    }
}

/// The system keyboard. Reads the settings the app approved and types into
/// whatever app is in front. Nothing typed is stored.
final class KeyboardViewController: UIInputViewController {
    private enum Edit {
        case inserted(String)
        case deleted(String)
    }

    private let state = KeyboardState(settings: SharedStore.loadSettings() ?? KeyboardSettings())
    private var undoStack: [Edit] = []
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = ExtensionKeyboardView(
            state: state,
            onPress: { [weak self] in self?.handle($0) },
            onCorrection: { [weak self] in self?.handle($0) }
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Pick up changes made in the app (new settings, "adjust for today").
        if let settings = SharedStore.loadSettings() {
            state.settings = settings
        }
        heightConstraint?.constant = state.height
        updateAutoShift()
    }

    override func textDidChange(_ textInput: (any UITextInput)?) {
        super.textDidChange(textInput)
        updateAutoShift()
    }

    private func handle(_ press: KeyPress) {
        switch press.key.action {
        case .character(let c):
            insert(state.isShifted ? c.uppercased() : c)
        case .space:
            insert(" ")
        case .returnKey:
            insert("\n")
        case .backspace:
            deleteBackward(count: 1)
        case .shift:
            state.isShifted.toggle()
            return
        case .nextKeyboard:
            advanceToNextInputMode()
            return
        }
        updateAutoShift()
    }

    private func handle(_ action: CorrectionAction) {
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

    private func updateAutoShift() {
        guard textDocumentProxy.autocapitalizationType != UITextAutocapitalizationType.none else {
            state.isShifted = false
            return
        }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let trimmed = before.trimmingCharacters(in: .whitespaces)
        state.isShifted = trimmed.isEmpty || before.hasSuffix("\n")
            || (before.hasSuffix(" ") && [".", "!", "?"].contains(trimmed.last))
    }
}

private struct ExtensionKeyboardView: View {
    let state: KeyboardState
    let onPress: (KeyPress) -> Void
    let onCorrection: (CorrectionAction) -> Void

    var body: some View {
        KeyboardView(
            size: state.settings.keySize,
            behavior: state.settings.behavior,
            systemKeys: true,
            showsCorrectionBar: state.settings.correctionBarEnabled,
            isShifted: state.isShifted,
            onPress: onPress,
            onCorrection: onCorrection
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Theme.neutral200)
    }
}
