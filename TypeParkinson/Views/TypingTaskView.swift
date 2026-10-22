import SwiftUI

/// Copy a phrase with the in-app keyboard. Used by the fifth exercise, both
/// rounds of the check, and typing practice.
struct TypingTaskView: View {
    let target: String
    /// `nil` types on a standard keyboard: no personal settings, no smart correction.
    var settings: KeyboardSettings?
    var simulation: TouchSimulation?
    let onFinish: (TypingOutcome) -> Void

    @State private var composer: TextComposer
    @State private var outcome = TypingOutcome(phrase: PhraseResult(errors: 0, corrections: 0, time: 0))

    init(target: String, settings: KeyboardSettings? = nil, simulation: TouchSimulation? = nil,
         onFinish: @escaping (TypingOutcome) -> Void) {
        self.target = target
        self.settings = settings
        self.simulation = simulation
        self.onFinish = onFinish
        // The phrases are lower case, so no automatic capitals; no word suggestions,
        // so the comparison measures typing rather than picking.
        _composer = State(initialValue: TextComposer(settings: settings, suggestions: false, autoCapitalize: false))
    }

    var body: some View {
        VStack(spacing: Theme.Space.s4) {
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TYPE THIS")
                        .font(Theme.font(.caption, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(Theme.secondaryText)
                    Text(target)
                        .font(Theme.rounded(.title3, weight: .semibold))
                }
                Text(typedText)
                    .font(Theme.font(.title3))
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                    .padding(Theme.Space.s4)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous))
                    .accessibilityLabel("Typed so far: \(composer.text)")
                HStack {
                    Text(statsText)
                        .font(Theme.font(.footnote))
                        .foregroundStyle(Theme.secondaryText)
                        .contentTransition(.numericText())
                    Spacer()
                    Button("Done", action: finish)
                        .buttonStyle(TPButtonStyle(minHeight: 44, fullWidth: false))
                        .disabled(composer.isEmpty)
                }
            }
            .padding(.horizontal, Theme.Space.s5)

            Spacer(minLength: 0)

            VStack(spacing: 6) {
                if settings?.smartCorrectionEnabled == true, composer.correction != nil {
                    SuggestionBar(suggestions: [], correction: composer.correction, showsPhrasesButton: false,
                                  isShowingPhrases: false, palette: theme.palette,
                                  onPick: { _ in }, onTogglePhrases: {},
                                  onRevert: { composer.revertCorrection(to: nil) },
                                  onPickAlternative: { composer.revertCorrection(to: $0) })
                        .transition(.opacity)
                }
                KeyboardView(
                    size: settings?.keySize ?? .standard,
                    behavior: settings?.behavior ?? .standard,
                    showsCorrectionBar: settings?.correctionBarEnabled ?? false,
                    theme: theme,
                    largeLabels: settings?.largeLabels ?? false,
                    showsKeyPreview: settings?.keyPreviewEnabled ?? false,
                    simulation: simulation,
                    onPress: press,
                    onBlockedRepeat: { outcome.blockedRepeats += 1 },
                    onIgnoredBrush: { outcome.ignoredBrushes += 1 },
                    onCorrection: { composer.correct($0) }
                )
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(theme.palette.background)
            .animation(.easeOut(duration: 0.15), value: composer.correction)
        }
    }

    private var theme: KeyboardTheme { settings?.theme ?? .classic }

    private var typedText: AttributedString {
        let expected = Array(target)
        var result = AttributedString()
        for (i, c) in composer.text.enumerated() {
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
        let n = composer.manualCorrections
        var parts = ["\(n) correction\(n == 1 ? "" : "s")"]
        if composer.autoCorrections > 0 {
            parts.append("\(composer.autoCorrections) fixed for you")
        }
        if composer.startTime == nil { parts.append("timer starts on first key") }
        return parts.joined(separator: " · ")
    }

    private func press(_ press: KeyPress) {
        outcome.taps += 1
        let position = composer.text.count
        if let uncorrected = press.uncorrectedKey, uncorrected.id != press.key.id, position < target.count {
            let expected = String(Array(target)[position])
            if press.key.id == expected {
                outcome.corrected += 1
            } else if uncorrected.id == expected {
                outcome.hurt += 1
            }
        }
        composer.press(press)
    }

    private func finish() {
        outcome.autoCorrected = composer.autoCorrections
        outcome.phrase = PhraseResult(
            errors: levenshtein(composer.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), target),
            corrections: composer.manualCorrections,
            time: composer.startTime.map { Date.now.timeIntervalSince($0) } ?? 0
        )
        onFinish(outcome)
    }
}
