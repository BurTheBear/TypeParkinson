import AVFoundation
import Observation

/// Reads text aloud for Speak. Parkinson's often makes the voice quieter or
/// harder to start, so typing and tapping Speak can be easier than talking.
@Observable
final class Speaker: NSObject, AVSpeechSynthesizerDelegate {
    enum Rate: String, CaseIterable, Identifiable {
        case slower, normal, faster

        var id: String { rawValue }
        var label: String { rawValue.capitalized }

        var value: Float {
            switch self {
            case .slower: AVSpeechUtteranceDefaultSpeechRate * 0.8
            case .normal: AVSpeechUtteranceDefaultSpeechRate
            case .faster: AVSpeechUtteranceDefaultSpeechRate * 1.15
            }
        }
    }

    private(set) var isSpeaking = false
    var rate: Rate {
        didSet { UserDefaults.standard.set(rate.rawValue, forKey: Self.rateKey) }
    }

    /// Made on first use: starting the speech engine at launch would delay the first screen.
    @ObservationIgnored private lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        return synthesizer
    }()
    private static let rateKey = "speechRate"

    override init() {
        rate = UserDefaults.standard.string(forKey: Self.rateKey).flatMap(Rate.init) ?? .normal
        super.init()
    }

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Play even with the ring switch on silent: the person chose to be heard.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = rate.value
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        guard isSpeaking else { return }
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finished() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finished() }
    }

    private func finished() {
        guard !synthesizer.isSpeaking else { return }
        isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
