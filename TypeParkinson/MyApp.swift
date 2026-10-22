import SwiftUI
import UserNotifications

@main struct MyApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationRouter.shared
        MedicationReminders.registerCategory()
        Appearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Navigation titles in SF Pro Rounded, to match the rounded numbers throughout.
enum Appearance {
    static func apply() {
        let nav = UINavigationBar.appearance()
        nav.largeTitleTextAttributes = [.font: rounded(size: 34, weight: .bold, style: .largeTitle)]
        nav.titleTextAttributes = [.font: rounded(size: 17, weight: .semibold, style: .headline)]
    }

    private static func rounded(size: CGFloat, weight: UIFont.Weight, style: UIFont.TextStyle) -> UIFont {
        let system = UIFont.systemFont(ofSize: size, weight: weight)
        let font = system.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: size) } ?? system
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}
