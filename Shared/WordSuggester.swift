import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Word completions for the suggestion bar, from the system's on-device
/// dictionary. Nothing typed leaves the device or is stored.
///
/// Fewer key presses means fewer chances for a tremor to land on the wrong
/// key: picking "tomorrow" after "tom" saves five taps.
final class WordSuggester {
    #if canImport(UIKit)
    private let checker = UITextChecker()
    #endif
    private let language: String

    init() {
        #if canImport(UIKit)
        language = UITextChecker.availableLanguages.first { $0.hasPrefix("en") } ?? "en_US"
        #else
        language = "en_US"
        #endif
    }

    /// The word being typed at the end of `context`: trailing letters and apostrophes.
    static func partialWord(in context: String) -> String {
        String(context.reversed().prefix { $0.isLetter || $0 == "'" || $0 == "’" }.reversed())
    }

    /// Up to `limit` words that finish or fix the word being typed, most likely first.
    func suggestions(for context: String, limit: Int = 3) -> [String] {
        let partial = Self.partialWord(in: context)
        guard !partial.isEmpty else { return [] }
        #if canImport(UIKit)
        let range = NSRange(location: 0, length: (partial as NSString).length)
        var words: [String] = []

        // A misspelling first gets the checker's best fix, the way the system keyboard offers it.
        let misspelled = partial.count > 2 && checker.rangeOfMisspelledWord(
            in: partial, range: range, startingAt: 0, wrap: false, language: language).location != NSNotFound
        if misspelled, let guess = checker.guesses(forWordRange: range, in: partial, language: language)?.first {
            words.append(guess)
        }
        words += checker.completions(forPartialWordRange: range, in: partial, language: language) ?? []

        var seen: Set<String> = [partial.lowercased()]
        var result: [String] = []
        for word in words where !word.contains(" ") {
            let key = word.lowercased()
            guard seen.insert(key).inserted else { continue }
            result.append(Self.matchCase(word, to: partial))
            if result.count == limit { break }
        }
        return result
        #else
        return []
        #endif
    }

    /// "Tom" → "Tomorrow", "TOM" → "TOMORROW", "tom" → "tomorrow".
    static func matchCase(_ word: String, to partial: String) -> String {
        guard let first = partial.first, first.isUppercase else { return word }
        if partial.count > 1, partial.allSatisfy({ !$0.isLetter || $0.isUppercase }) {
            return word.uppercased()
        }
        return word.prefix(1).uppercased() + word.dropFirst()
    }
}
