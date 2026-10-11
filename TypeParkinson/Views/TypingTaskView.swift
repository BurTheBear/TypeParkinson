import SwiftUI

/// Copy a phrase with the in-app keyboard. Used by the fifth exercise and both
/// rounds of the check.
struct TypingTaskView: View {
    let target: String
    /// `nil` types on a standard keyboard.
    var settings: KeyboardSettings?
    var simulation: TouchSimulation?
    let onFinish: (TypingOutcome) -> Void

    @State private var typed = ""
    @State private var history: [String] = []
    @State private var corrections = 0
    @State private var startTime: Date?
    @State private var outcome = TypingOutcome(phrase: PhraseResult(errors: 0, corrections: 0, time: 0))

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Type this")
                        .font(Theme.serif(.caption))
                        .foregroundStyle(Theme.secondaryText)
                    Text(target)
                        .font(Theme.serif(.title3))
                }
                Text(typedText)
                    .font(Theme.serif(.title3))
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
                    .padding(14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .accessibilityLabel("Typed so far: \(typed)")
                HStack {
                    Text(statsText)
                        .font(Theme.serif(.caption))
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    Button("Done", action: finish)
                        .buttonStyle(TPButtonStyle(minHeight: 44, fullWidth: false))
                        .disabled(typed.isEmpty)
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 0)

            KeyboardView(
                size: settings?.keySize ?? .standard,
                behavior: settings?.behavior ?? .standard,
                showsCorrectionBar: settings?.correctionBarEnabled ?? false,
                simulation: simulation,
                onPress: press,
                onBlockedRepeat: { outcome.blockedRepeats += 1 },
                onCorrection: correct
            )
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(Theme.neutral200)
        }
    }

    private var typedText: AttributedString {
        let expected = Array(target)
        var result = AttributedString()
        for (i, c) in typed.enumerated() {
            var piece = AttributedString(String(c))
            if i >= expected.count || expected[i] != c {
                piece.foregroundColor = Theme.warning
                piece.underlineStyle = .single
            }
            result += piece
        }
        var caret = AttributedString("|")
        caret.foregroundColor = Theme.accent
        return result + caret
    }

    private var statsText: String {
        "\(corrections) correction\(corrections == 1 ? "" : "s")" + (startTime == nil ? " · timer starts on first key" : "")
    }

    private func press(_ press: KeyPress) {
        outcome.taps += 1
        if let uncorrected = press.uncorrectedKey, uncorrected.id != press.key.id, typed.count < target.count {
            let expected = String(Array(target)[typed.count])
            if press.key.id == expected {
                outcome.corrected += 1
            } else if uncorrected.id == expected {
                outcome.hurt += 1
            }
        }
        switch press.key.action {
        case .character(let c): append(c)
        case .space: append(" ")
        case .backspace: deleteLast()
        default: break
        }
    }

    private func correct(_ action: CorrectionAction) {
        switch action {
        case .backspace:
            deleteLast()
        case .undo:
            guard let previous = history.popLast() else { return }
            typed = previous
            corrections += 1
        case .deleteWord:
            guard !typed.isEmpty else { return }
            remember()
            let spaces = typed.reversed().prefix { $0 == " " }.count
            let word = typed.dropLast(spaces).reversed().prefix { $0 != " " }.count
            typed.removeLast(word + spaces)
            corrections += 1
        }
    }

    private func append(_ text: String) {
        if startTime == nil { startTime = .now }
        remember()
        typed += text
    }

    private func deleteLast() {
        guard !typed.isEmpty else { return }
        remember()
        typed.removeLast()
        corrections += 1
    }

    private func remember() {
        history.append(typed)
        if history.count > 60 { history.removeFirst() }
    }

    private func finish() {
        outcome.phrase = PhraseResult(
            errors: levenshtein(typed.trimmingCharacters(in: .whitespaces), target),
            corrections: corrections,
            time: startTime.map { Date.now.timeIntervalSince($0) } ?? 0
        )
        onFinish(outcome)
    }
}
