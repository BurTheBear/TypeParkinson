import Foundation
import Observation

enum Phrases {
    static let exercise = "meet me at the library at noon"
    static let standardRound = "the dog ran past the old mill"
    static let personalRound = "a cup of tea sits by the door"
}

struct TypingOutcome: Equatable {
    var phrase: PhraseResult
    /// Taps the offset moved onto the expected key, and off it.
    var corrected = 0
    var hurt = 0
    var blockedRepeats = 0
    var taps = 0
}

struct CheckResult: Equatable {
    var standard: TypingOutcome
    var personal: TypingOutcome
}

@Observable
final class AppModel {
    enum Screen: String {
        case onboarding
        case signUp
        case welcome
        case exercises
        case recalibration
        case profile
        case proposal
        case check
        case compare
        case enable
        case home
        case recalResult
    }

    var screen: Screen
    var hand: Hand = .right
    private(set) var profile: TouchProfile?
    /// The working copy being proposed or edited; the keyboard only sees it once approved.
    var settings: KeyboardSettings
    private(set) var checkResult: CheckResult?
    private(set) var todayTaps: [TapSample] = []
    private(set) var isSetupComplete: Bool
    /// Signed up with the placeholder account and still showing the sample profile.
    private(set) var usesSampleData: Bool
    /// The profile screen was opened from home rather than straight after the exercises.
    private(set) var isViewingSavedProfile = false

    var simulateTremor: Bool
    var simulator: TremorSimulator { TremorSimulator(strength: simulateTremor ? 1 : 0) }

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let profile = "touchProfile"
        static let setupComplete = "setupComplete"
        static let signedUp = "signedUp"
        static let usesSampleData = "usesSampleData"
    }

    init() {
        let profile = defaults.data(forKey: Keys.profile)
            .flatMap { try? JSONDecoder().decode(TouchProfile.self, from: $0) }
        let complete = defaults.bool(forKey: Keys.setupComplete) && profile != nil
        self.profile = profile
        self.hand = profile?.hand ?? .right
        self.isSetupComplete = complete
        self.usesSampleData = defaults.bool(forKey: Keys.usesSampleData)
        self.settings = SharedStore.loadSettings() ?? profile?.proposedSettings() ?? KeyboardSettings()
        if !defaults.bool(forKey: Keys.signedUp) {
            self.screen = .onboarding
        } else {
            self.screen = complete ? .home : .welcome
        }
        #if targetEnvironment(simulator)
        self.simulateTremor = true
        #else
        self.simulateTremor = false
        #endif
        #if DEBUG
        // e.g. `-demoScreen proposal` opens that screen with sample data.
        if let name = defaults.string(forKey: "demoScreen"), let demo = Screen(rawValue: name) {
            loadDemo(demo)
        }
        #endif
    }

    // MARK: Onboarding

    func finishOnboarding() {
        screen = .signUp
    }

    /// Placeholder until accounts exist: nothing entered is stored or sent.
    /// Fills the app with the sample profile and goes straight to home.
    func signUp() {
        let sample = TouchProfile.sample
        profile = sample
        hand = sample.hand
        save(profile: sample)
        settings = sample.proposedSettings()
        SharedStore.save(settings)
        usesSampleData = true
        isSetupComplete = true
        defaults.set(true, forKey: Keys.signedUp)
        defaults.set(true, forKey: Keys.usesSampleData)
        defaults.set(true, forKey: Keys.setupComplete)
        screen = .home
    }

    // MARK: Setup

    func startExercises() {
        screen = .exercises
    }

    func finishExercises(_ newProfile: TouchProfile) {
        isViewingSavedProfile = false
        usesSampleData = false
        defaults.set(false, forKey: Keys.usesSampleData)
        profile = newProfile
        settings = newProfile.proposedSettings()
        checkResult = nil
        save(profile: newProfile)
        screen = .profile
    }

    func startCheck() {
        screen = .check
    }

    func finishCheck(_ result: CheckResult) {
        checkResult = result
        screen = .compare
    }

    /// Saves the working settings for the keyboard to use.
    func approve() {
        settings.todayOffset = nil
        SharedStore.save(settings)
        screen = isSetupComplete ? .home : .enable
    }

    func finishSetup() {
        isSetupComplete = true
        defaults.set(true, forKey: Keys.setupComplete)
        screen = .home
    }

    /// Drops unapproved edits and returns home.
    func cancelEditing() {
        settings = SharedStore.loadSettings() ?? settings
        screen = .home
    }

    func leaveSetup() {
        if isSetupComplete { cancelEditing() } else { screen = .welcome }
    }

    // MARK: Everyday use

    func viewProfile() {
        isViewingSavedProfile = true
        screen = .profile
    }

    func startRecalibration() {
        screen = .recalibration
    }

    func finishRecalibration(_ taps: [TapSample]) {
        todayTaps = taps
        screen = .recalResult
    }

    func applyToday() {
        let offset = todayTaps.meanOffset
        updateSaved { $0.todayOffset = .init(x: offset.dx, y: offset.dy, date: .now) }
        screen = .home
    }

    func clearToday() {
        updateSaved { $0.todayOffset = nil }
    }

    var todayOffset: KeyboardSettings.TodayOffset? {
        settings.todayOffset.flatMap { $0.isCurrent ? $0 : nil }
    }

    private func updateSaved(_ change: (inout KeyboardSettings) -> Void) {
        var saved = SharedStore.loadSettings() ?? settings
        change(&saved)
        SharedStore.save(saved)
        settings = saved
    }

    private func save(profile: TouchProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: Keys.profile)
        }
    }
}

// MARK: - Demo data

#if DEBUG
/// Sample data for opening any screen directly from a launch argument, so each
/// screen can be checked without tapping through the whole flow.
extension AppModel {
    func loadDemo(_ demo: Screen) {
        let simulator = TremorSimulator(strength: 1)
        let profile = TouchProfile.sample
        self.profile = profile
        settings = profile.proposedSettings()
        checkResult = CheckResult(
            standard: TypingOutcome(phrase: PhraseResult(errors: 4, corrections: 6, time: 21.3)),
            personal: TypingOutcome(phrase: PhraseResult(errors: 1, corrections: 2, time: 17.8),
                                    corrected: 6, hurt: 1, blockedRepeats: 2, taps: 34))
        todayTaps = (0..<6).map { _ in
            let d = simulator.tapDisplacement()
            return TapSample(isCluster: false, dx: d.dx + 6, dy: d.dy + 5, hit: false)
        }
        isSetupComplete = [.home, .recalResult].contains(demo)
        usesSampleData = demo == .home
        screen = demo
    }
}
#endif
