import AppIntents
import Foundation
import Observation
import UserNotifications

/// The app's main sections once setup is done.
enum AppTab: String, Hashable, CaseIterable {
    case today, practice, speak, progress, settings
}

/// The tracked activities in Practice.
enum PracticeActivity: String, Identifiable, CaseIterable, Codable {
    case spiral, tapping, typing, tremor, voice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spiral: "Trace a spiral"
        case .tapping: "Rhythm tapping"
        case .typing: "Typing practice"
        case .tremor: "Tremor meter"
        case .voice: "Voice volume"
        }
    }

    var summary: String {
        switch self {
        case .spiral: "Follow a spiral from the centre out. Measures how closely and smoothly you trace."
        case .tapping: "Tap two targets in turn for ten seconds. Measures speed and how even your rhythm is."
        case .typing: "Copy one everyday sentence on your own keyboard. Measures speed and accuracy."
        case .tremor: "Hold your phone for ten seconds. Its motion sensors measure how much your hand shakes, and how fast."
        case .voice: "Say “ahh” loudly and steadily. Practises a strong voice, inspired by speech therapy for Parkinson’s."
        }
    }

    var duration: String {
        switch self {
        case .spiral: "About 20 seconds"
        case .tapping: "10 seconds"
        case .typing: "About a minute"
        case .tremor: "10 seconds"
        case .voice: "6 seconds"
        }
    }

    var symbol: String {
        switch self {
        case .spiral: "hurricane"
        case .tapping: "hand.tap.fill"
        case .typing: "keyboard.fill"
        case .tremor: "waveform.path.ecg"
        case .voice: "mic.fill"
        }
    }
}

/// Where Siri, Shortcuts or a notification asked the app to go. ContentView
/// picks it up once the app is in front.
@Observable
final class AppRouter {
    static let shared = AppRouter()

    enum Route: Equatable {
        case dailyCheck
        case speak
        case practice(PracticeActivity)
        case progress
        case medications
    }

    var pending: Route?
}

// MARK: - Siri and Shortcuts

nonisolated struct StartDailyCheckIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Today’s Check"
    static let description = IntentDescription("Opens TypeParkinson’s six-tap daily check.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .dailyCheck
        return .result()
    }
}

nonisolated struct OpenSpeakIntent: AppIntent {
    static let title: LocalizedStringResource = "Speak for Me"
    static let description = IntentDescription("Opens TypeParkinson’s Speak screen to type something to say out loud.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .speak
        return .result()
    }
}

nonisolated struct TraceSpiralIntent: AppIntent {
    static let title: LocalizedStringResource = "Trace a Spiral"
    static let description = IntentDescription("Opens TypeParkinson’s spiral exercise.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .practice(.spiral)
        return .result()
    }
}

nonisolated struct TremorMeterIntent: AppIntent {
    static let title: LocalizedStringResource = "Measure Tremor"
    static let description = IntentDescription("Opens TypeParkinson’s ten-second tremor meter.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .practice(.tremor)
        return .result()
    }
}

nonisolated struct TypeParkinsonShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartDailyCheckIntent(),
                    phrases: ["Start my \(.applicationName) check", "Check my hands in \(.applicationName)"],
                    shortTitle: "Daily check", systemImageName: "hand.tap")
        AppShortcut(intent: OpenSpeakIntent(),
                    phrases: ["Speak for me with \(.applicationName)", "Open \(.applicationName) Speak"],
                    shortTitle: "Speak", systemImageName: "text.bubble")
        AppShortcut(intent: TremorMeterIntent(),
                    phrases: ["Measure my tremor with \(.applicationName)", "Start the \(.applicationName) tremor meter"],
                    shortTitle: "Tremor meter", systemImageName: "waveform.path.ecg")
        AppShortcut(intent: TraceSpiralIntent(),
                    phrases: ["Trace a spiral in \(.applicationName)"],
                    shortTitle: "Trace a spiral", systemImageName: "hurricane")
    }
}

// MARK: - Daily reminder

enum Reminders {
    static let identifier = "daily-check"

    /// Asks for permission the first time. Returns false if notifications are off for the app.
    static func schedule(hour: Int, minute: Int) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return false }
        let content = UNMutableNotificationContent()
        content.title = "Time for today’s check"
        content.body = "Six taps, about 30 seconds. See how your hands are today and tune the keyboard to match."
        content.sound = .default
        var time = DateComponents()
        time.hour = hour
        time.minute = minute
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(identifier: identifier, content: content,
                                            trigger: UNCalendarNotificationTrigger(dateMatching: time, repeats: true))
        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

/// Opens the daily check when its reminder is tapped, and logs a dose when a
/// medication reminder's "Took it" is pressed, even with the app closed.
final class NotificationRouter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationRouter()

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        let request = response.notification.request
        let info = request.content.userInfo
        let medID = (info["medicationID"] as? String).flatMap(UUID.init(uuidString:))
        let name = info["name"] as? String
        let action = response.actionIdentifier
        await MainActor.run {
            if request.identifier == Reminders.identifier {
                AppRouter.shared.pending = .dailyCheck
            } else if let medID, let name, action == MedicationReminders.tookItAction {
                ActivityStore.shared.add(DoseRecord(date: .now, medicationID: medID, name: name))
            } else if medID != nil {
                AppRouter.shared.pending = .medications
            }
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
