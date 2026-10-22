import SwiftUI

/// The row above the keys: a Phrases button and up to three word completions.
/// Every target is a full-height button, never a thin text link.
struct SuggestionBar: View {
    /// A word smart correction just changed, so it can be put back with one tap.
    struct Correction: Equatable {
        var typed: String
        var corrected: String
        var separator: String
        var alternatives: [String]
    }

    var suggestions: [String]
    var correction: Correction? = nil
    var showsPhrasesButton: Bool
    var isShowingPhrases: Bool
    var palette: KeyboardTheme.Palette
    var compact = false
    var largeLabels = false
    var onPick: (String) -> Void
    var onTogglePhrases: () -> Void
    var onRevert: () -> Void = {}
    var onPickAlternative: (String) -> Void = { _ in }

    static func height(compact: Bool) -> CGFloat { compact ? 36 : 46 }

    var body: some View {
        HStack(spacing: 6) {
            if showsPhrasesButton {
                Button(action: onTogglePhrases) {
                    Label(isShowingPhrases ? "Keys" : "Phrases",
                          systemImage: isShowingPhrases ? "keyboard" : "text.bubble")
                        .font(Theme.font(size: largeLabels ? 16 : 14, weight: .semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .frame(maxHeight: .infinity)
                        .background(isShowingPhrases ? palette.pressed : palette.functionKey,
                                    in: RoundedRectangle(cornerRadius: Theme.keyRadius, style: .continuous))
                        .foregroundStyle(isShowingPhrases ? palette.pressedLabel : palette.label)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isShowingPhrases ? "Back to keys" : "Saved phrases")
            }
            if !isShowingPhrases, let correction {
                Button(action: onRevert) {
                    Label("“\(correction.typed)”", systemImage: "arrow.uturn.backward")
                        .font(Theme.font(size: largeLabels ? 18 : 16, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(palette.functionKey, in: RoundedRectangle(cornerRadius: Theme.keyRadius, style: .continuous))
                        .foregroundStyle(palette.label)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Change back to \(correction.typed)")
                ForEach(correction.alternatives.prefix(2), id: \.self) { word in
                    Button { onPickAlternative(word) } label: {
                        Text(word)
                            .font(Theme.font(size: largeLabels ? 20 : 17))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(palette.inputKey.opacity(0.7),
                                        in: RoundedRectangle(cornerRadius: Theme.keyRadius, style: .continuous))
                            .foregroundStyle(palette.label)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Change to \(word)")
                }
            } else if !isShowingPhrases {
                ForEach(Array(suggestions.prefix(3).enumerated()), id: \.offset) { index, word in
                    Button { onPick(word) } label: {
                        Text(word)
                            .font(Theme.font(size: largeLabels ? 20 : 17, weight: index == 0 ? .semibold : .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(palette.inputKey.opacity(0.7),
                                        in: RoundedRectangle(cornerRadius: Theme.keyRadius, style: .continuous))
                            .foregroundStyle(palette.label)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Suggestion: \(word)")
                }
                if suggestions.isEmpty {
                    Spacer(minLength: 0)
                }
            } else {
                Text("Tap a phrase to type it")
                    .font(Theme.font(size: 13))
                    .foregroundStyle(palette.label.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: Self.height(compact: compact))
    }
}

/// Big buttons for the person's saved phrases. Takes the place of the keys,
/// at the same height, so nothing on screen jumps.
struct PhrasePanel: View {
    var phrases: [QuickPhrase]
    var palette: KeyboardTheme.Palette
    var height: CGFloat
    var largeLabels = false
    var onPick: (QuickPhrase) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                ForEach(phrases) { phrase in
                    Button { onPick(phrase) } label: {
                        Text(phrase.text)
                            .font(Theme.font(size: largeLabels ? 18 : 16, weight: .medium))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                            .background(palette.inputKey, in: RoundedRectangle(cornerRadius: Theme.keyRadius, style: .continuous))
                            .shadow(color: palette.keyShadow, radius: 0, x: 0, y: 1)
                            .foregroundStyle(palette.label)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(height: height)
        .overlay {
            if phrases.isEmpty {
                Text("No saved phrases yet. Add some in the TypeParkinson app.")
                    .font(Theme.font(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(palette.label)
                    .padding()
            }
        }
    }
}
