import Foundation

/// Something the person says often, typed or spoken with one tap.
struct QuickPhrase: Codable, Identifiable, Hashable {
    var id = UUID()
    var text: String
}

extension QuickPhrase {
    /// What a new person starts with. They can edit, reorder or delete all of them.
    static let starters: [QuickPhrase] = [
        "On my way.",
        "Yes, thank you!",
        "I'll call you back soon.",
        "Running a few minutes late.",
        "Can you help me with this?",
        "Love you. Talk soon.",
    ].map { QuickPhrase(text: $0) }

    /// What the keyboard and Speak show: the saved list, or the starters before anything was saved.
    static var current: [QuickPhrase] {
        SharedStore.loadPhrases() ?? starters
    }
}
