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
    /// The profile screen was opened from home rather than straight after the exercises.
    private(set) var isViewingSavedProfile = false

    var simulateTremor: Bool
    var simulator: TremorSimulator { TremorSimulator(strength: simulateTremor ? 1 : 0) }

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let profile = "touchProfile"
        static let setupComplete = "setupComplete"
    }

    init() {
        let profile = defaults.data(forKey: Keys.profile)
            .flatMap { try? JSONDecoder().decode(TouchProfile.self, from: $0) }
        let complete = defaults.bool(forKey: Keys.setupComplete) && profile != nil
        self.profile = profile
        self.hand = profile?.hand ?? .right
        self.isSetupComplete = complete
        self.settings = SharedStore.loadSettings() ?? profile?.proposedSettings() ?? KeyboardSettings()
        self.screen = complete ? .home : .welcome
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

    // MARK: Setup

    func startExercises() {
        screen = .exercises
    }

    func finishExercises(_ newProfile: TouchProfile) {
        isViewingSavedProfile = false
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
        let taps = (0..<10).map { i in
            let d = simulator.tapDisplacement()
            return TapSample(isCluster: i % 2 == 1, dx: d.dx, dy: d.dy, hit: hypot(d.dx, d.dy) < (i % 2 == 1 ? 14 : 26))
        }
        let profile = TouchProfile(
            hand: .right, taps: taps,
            doubleTaps: [.init(interval: 0.31, contacts: 2), .init(interval: 0.28, contacts: 3),
                         .init(interval: 0.35, contacts: 2), .init(interval: 0.30, contacts: 3)],
            holds: [.init(duration: 0.41, movement: 7), .init(duration: 0.38, movement: 9),
                    .init(duration: 0.52, movement: 6), .init(duration: 0.44, movement: 8)],
            pathDeviation: 8.6,
            phrase: PhraseResult(errors: 3, corrections: 5, time: 24))
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
        screen = demo
    }
}
#endif
