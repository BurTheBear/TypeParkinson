import SwiftUI

struct ContentView: View {
    @State private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase
    private let router = AppRouter.shared

    var body: some View {
        screen
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.bg.ignoresSafeArea())
            .tint(Theme.accent)
            .environment(model)
            .animation(.easeInOut(duration: 0.25), value: model.screen)
            .task { await model.verifyAppleCredential() }
            .task { await model.observeCloudChanges() }
            .task { await model.observeCredentialRevocation() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    CloudStore.refresh()
                    model.pullFromCloud()
                    model.activity.reload()
                    followPendingRoute()
                }
            }
            .onChange(of: router.pending) { _, _ in followPendingRoute() }
            .alert("TypeParkinson", isPresented: Binding(get: { model.notice != nil },
                                                         set: { if !$0 { model.notice = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(model.notice ?? "")
            }
    }

    @ViewBuilder private var screen: some View {
        switch model.screen {
        case .onboarding: OnboardingView()
        case .account: AccountView()
        case .welcome: WelcomeView()
        case .exercises: ExerciseFlowView(recalibration: false)
        case .recalibration: ExerciseFlowView(recalibration: true)
        case .profile: ProfileView()
        case .proposal: ProposalView()
        case .check: CheckView()
        case .compare: CompareView()
        case .enable: EnableView()
        case .home, .settings: MainTabView()
        case .recalResult: RecalResultView()
        }
    }

    /// Siri, Shortcuts and the reminder set a route; follow it once we're in front.
    private func followPendingRoute() {
        guard scenePhase == .active, let route = router.pending else { return }
        router.pending = nil
        model.follow(route)
    }
}

/// The everyday app, once setup is done.
struct MainTabView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        TabView(selection: $model.tab) {
            Tab("Today", systemImage: "newspaper", value: AppTab.today) {
                TodayView()
            }
            Tab("Practice", systemImage: "hand.draw", value: AppTab.practice) {
                PracticeView()
            }
            Tab("Speak", systemImage: "text.bubble", value: AppTab.speak) {
                SpeakView()
            }
            Tab("Progress", systemImage: "chart.xyaxis.line", value: AppTab.progress) {
                ProgressScreen()
            }
            Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

#Preview {
    ContentView()
}
