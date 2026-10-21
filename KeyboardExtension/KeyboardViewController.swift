import SwiftUI
import UIKit

@Observable
final class KeyboardState {
    var settings: KeyboardSettings
    var shift: ShiftState = .off
    var mode: KeyboardMode = .letters
    var options = KeyboardLayout.Options(systemKeys: true)
    var suggestions: [String] = []
    var correction: SuggestionBar.Correction?
    var phrases: [QuickPhrase] = QuickPhrase.current
    var isShowingPhrases = false

    init(settings: KeyboardSettings) {
        self.settings = settings
    }

    var showsTopBar: Bool {
        (settings.suggestionsEnabled || settings.phrasesEnabled || settings.smartCorrectionEnabled) && mode != .numberPad
    }

    /// Correction bar and keys: the area the phrase panel replaces.
    var keysAreaHeight: CGFloat {
        let bar = settings.correctionBarEnabled ? KeyboardView.correctionBarHeight(compact: options.compact) : 0
        return bar + settings.keySize.keyboardHeight(compact: options.compact)
    }

    /// Suggestion bar, keys and vertical padding.
    var height: CGFloat {
        let top = showsTopBar ? SuggestionBar.height(compact: options.compact) + 6 : 0
        return 16 + top + keysAreaHeight
    }
}

/// The system keyboard. Reads the settings the app approved and types into
/// whatever app is in front. Nothing typed is stored or sent anywhere; the only
/// thing it keeps is its touch model (a few numbers), in its own container.
final class KeyboardViewController: UIInputViewController {
    private enum Edit {
        case inserted(String)
        case deleted(String)
        /// A suggestion or smart correction replaced text.
        case replaced(old: String, new: String)
    }

    private let state = KeyboardState(settings: SharedStore.loadSettings() ?? KeyboardSettings())
    private let suggester = WordSuggester()
    private let decoder = IntentDecoder()
    private var undoStack: [Edit] = []
    /// Deletions from one hold of the delete key are undone together.
    private var isHoldingDelete = false
    private var heightConstraint: NSLayoutConstraint?
    private var lastKeyboardType: UIKeyboardType?
    /// The letters of the word being typed, with where each touch landed.
    private var wordTouches: [TypedTouch] = []
    private var lastLayout: KeyboardLayout?
    private var unsavedLearning = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = ExtensionKeyboardView(
            state: state,
            onPress: { [weak self] in self?.handle($0) },
            onCorrection: { [weak self] in self?.handle($0) },
            onRepeatDelete: { [weak self] in self?.repeatDelete() },
            onPickSuggestion: { [weak self] in self?.pick($0) },
            onPickPhrase: { [weak self] in self?.insertPhrase($0) },
            onRevert: { [weak self] in self?.revertCorrection(to: nil) },
            onPickAlternative: { [weak self] in self?.revertCorrection(to: $0) }
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
        // Pick up changes made in the app (new settings, "adjust for today", edited phrases).
        if let settings = SharedStore.loadSettings() {
            state.settings = settings
        }
        state.phrases = QuickPhrase.current
        state.isShowingPhrases = false
        state.correction = nil
        wordTouches = []
        loadTouchModel()
        updateOptions()
        updateAutoShift()
        updateSuggestions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTouchModel()
    }

    override func textDidChange(_ textInput: (any UITextInput)?) {
        super.textDidChange(textInput)
        updateOptions()
        updateAutoShift()
        updateSuggestions()
    }

    // MARK: Keys

    private func handle(_ press: KeyPress) {
        isHoldingDelete = false
        state.correction = nil
        switch press.key.action {
        case .character(let c):
            let text = state.shift != .off ? c.uppercased() : c
            if c.count == 1, let letter = text.first, letter.isLetter {
                insert(text)
                wordTouches.append(TypedTouch(character: letter, point: press.point, time: press.time))
                if let layout = press.layout { lastLayout = layout }
            } else if [".", ",", "!", "?", ";", ":"].contains(c) {
                commitWord(then: text)
            } else {
                insert(text)
                wordTouches = []
            }
            if state.shift == .once { state.shift = .off }
            // Like the standard keyboard, an apostrophe goes back to letters.
            if c == "'", state.mode != .numberPad { state.mode = .letters }
        case .space:
            commitWord(then: " ")
            if state.mode == .numbers || state.mode == .symbols { state.mode = .letters }
        case .returnKey:
            commitWord(then: "\n")
        case .backspace:
            deleteBackward(count: 1)
            if !wordTouches.isEmpty { wordTouches.removeLast() }
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
            updateSuggestions()
            return
        case .nextKeyboard:
            advanceToNextInputMode()
            return
        }
        updateAutoShift()
        updateSuggestions()
    }

    // MARK: Smart correction

    /// At the end of a word: work out what was meant, fix it if confident, then type the separator.
    private func commitWord(then separator: String) {
        let touches = wordTouches
        wordTouches = []
        let proxy = textDocumentProxy
        let typed = String(touches.map(\.character))
        guard state.settings.smartCorrectionEnabled, !touches.isEmpty, let layout = lastLayout,
              // Only if the text before the cursor is still exactly what these touches typed.
              WordSuggester.partialWord(in: proxy.documentContextBeforeInput ?? "") == typed
        else {
            insert(separator)
            return
        }
        let centers = IntentDecoder.keyCenters(layout)
        guard let decoded = decoder.decode(touches, keyCenters: centers) else {
            insert(separator)
            return
        }
        if decoded.shouldReplace {
            for _ in typed { proxy.deleteBackward() }
            let replacement = decoded.best + separator
            proxy.insertText(replacement)
            record(.replaced(old: typed + separator, new: replacement))
            state.correction = SuggestionBar.Correction(typed: typed, corrected: decoded.best, separator: separator,
                                                        alternatives: decoded.alternatives.filter { $0.lowercased() != typed.lowercased() })
        } else {
            insert(separator)
            // A real word kept as typed: learn where this person aims for each letter.
            if decoder.logPrior(typed.lowercased()) != nil {
                decoder.learn(word: typed, touches: touches, keyCenters: centers)
                unsavedLearning += 1
                if unsavedLearning >= 5 { saveTouchModel() }
            }
        }
    }

    /// Puts back what was typed (`nil`) or swaps in one of the alternatives.
    private func revertCorrection(to alternative: String?) {
        guard let correction = state.correction else { return }
        state.correction = nil
        let current = correction.corrected + correction.separator
        guard (textDocumentProxy.documentContextBeforeInput ?? "").hasSuffix(current) else { return }
        for _ in current { textDocumentProxy.deleteBackward() }
        let replacement = (alternative ?? correction.typed) + correction.separator
        textDocumentProxy.insertText(replacement)
        record(.replaced(old: current, new: replacement))
        updateAutoShift()
        updateSuggestions()
    }

    private static let learnedModelKey = "learnedTouchModel"
    private static let learnedBaseKey = "learnedTouchModelBase"

    /// Starts from the app's model, plus anything learned since that model was made.
    private func loadTouchModel() {
        let settings = state.settings
        let base = settings.touchModel ?? TouchModel()
        decoder.strength = settings.correctionStrength
        let defaults = UserDefaults.standard
        let savedBase = defaults.data(forKey: Self.learnedBaseKey).flatMap { try? JSONDecoder().decode(TouchModel.self, from: $0) }
        if savedBase == base,
           let learned = defaults.data(forKey: Self.learnedModelKey).flatMap({ try? JSONDecoder().decode(TouchModel.self, from: $0) }) {
            decoder.model = learned
        } else {
            // New exercises in the app: start again from them.
            decoder.model = base
            defaults.set(try? JSONEncoder().encode(base), forKey: Self.learnedBaseKey)
            defaults.removeObject(forKey: Self.learnedModelKey)
        }
    }

    private func saveTouchModel() {
        guard unsavedLearning > 0 else { return }
        UserDefaults.standard.set(try? JSONEncoder().encode(decoder.model), forKey: Self.learnedModelKey)
        unsavedLearning = 0
    }

    // MARK: Editing

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
        wordTouches = []
        state.correction = nil
        updateAutoShift()
        updateSuggestions()
    }

    private func handle(_ action: CorrectionAction) {
        isHoldingDelete = false
        state.correction = nil
        switch action {
        case .backspace:
            deleteBackward(count: 1)
            if !wordTouches.isEmpty { wordTouches.removeLast() }
        case .deleteWord:
            deleteBackward(count: trailingWordLength(textDocumentProxy.documentContextBeforeInput ?? ""))
            wordTouches = []
        case .undo:
            wordTouches = []
            guard let edit = undoStack.popLast() else { return }
            switch edit {
            case .inserted(let text):
                for _ in text { textDocumentProxy.deleteBackward() }
            case .deleted(let text):
                textDocumentProxy.insertText(text)
            case .replaced(let old, let new):
                for _ in new { textDocumentProxy.deleteBackward() }
                textDocumentProxy.insertText(old)
            }
        }
        updateAutoShift()
        updateSuggestions()
    }

    /// Replaces the word being typed with the suggestion, plus a space.
    private func pick(_ word: String) {
        isHoldingDelete = false
        state.correction = nil
        let partial = WordSuggester.partialWord(in: textDocumentProxy.documentContextBeforeInput ?? "")
        for _ in partial { textDocumentProxy.deleteBackward() }
        let replacement = word + " "
        textDocumentProxy.insertText(replacement)
        record(.replaced(old: partial, new: replacement))
        wordTouches = []
        if state.shift == .once { state.shift = .off }
        updateAutoShift()
        updateSuggestions()
    }

    /// Types a saved phrase, with a space before it if it would otherwise join the previous word.
    private func insertPhrase(_ phrase: QuickPhrase) {
        isHoldingDelete = false
        state.correction = nil
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let needsSpace = before.last.map { !$0.isWhitespace } ?? false
        insert((needsSpace ? " " : "") + phrase.text)
        wordTouches = []
        state.isShowingPhrases = false
        updateAutoShift()
        updateSuggestions()
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

    private func updateSuggestions() {
        let proxy = textDocumentProxy
        // Never suggest in secure fields, and only on the letters layer.
        guard state.settings.suggestionsEnabled, state.mode == .letters, proxy.isSecureTextEntry != true else {
            if !state.suggestions.isEmpty { state.suggestions = [] }
            return
        }
        let next = suggester.suggestions(for: proxy.documentContextBeforeInput ?? "")
        if next != state.suggestions { state.suggestions = next }
    }

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
    let onPickSuggestion: (String) -> Void
    let onPickPhrase: (QuickPhrase) -> Void
    let onRevert: () -> Void
    let onPickAlternative: (String) -> Void

    var body: some View {
        var options = state.options
        options.mode = state.mode
        let settings = state.settings
        let palette = settings.theme.palette
        return VStack(spacing: 6) {
            if state.showsTopBar {
                SuggestionBar(suggestions: settings.suggestionsEnabled ? state.suggestions : [],
                              correction: state.correction,
                              showsPhrasesButton: settings.phrasesEnabled,
                              isShowingPhrases: state.isShowingPhrases,
                              palette: palette, compact: options.compact, largeLabels: settings.largeLabels,
                              onPick: onPickSuggestion,
                              onTogglePhrases: { state.isShowingPhrases.toggle() },
                              onRevert: onRevert,
                              onPickAlternative: onPickAlternative)
            }
            if state.isShowingPhrases {
                PhrasePanel(phrases: state.phrases, palette: palette, height: state.keysAreaHeight,
                            largeLabels: settings.largeLabels, onPick: onPickPhrase)
            } else {
                KeyboardView(
                    size: settings.keySize,
                    behavior: settings.behavior,
                    options: options,
                    showsCorrectionBar: settings.correctionBarEnabled,
                    shift: state.shift,
                    theme: settings.theme,
                    largeLabels: settings.largeLabels,
                    showsKeyPreview: settings.keyPreviewEnabled,
                    onPress: onPress,
                    onCorrection: onCorrection,
                    onRepeatDelete: settings.holdToDeleteEnabled ? onRepeatDelete : nil
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(palette.background)
    }
}
