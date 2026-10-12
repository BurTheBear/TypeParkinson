import SwiftUI

struct ContentView: View {
    @State private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        screen
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.bg.ignoresSafeArea())
            .foregroundStyle(Theme.text)
            .tint(Theme.accent)
            .environment(model)
            .animation(.easeInOut(duration: 0.2), value: model.screen)
            .task { await model.verifyAppleCredential() }
            .task { await model.observeCloudChanges() }
            .task { await model.observeCredentialRevocation() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    CloudStore.refresh()
                    model.pullFromCloud()
                }
            }
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
        case .home: HomeView()
        case .recalResult: RecalResultView()
        case .settings: SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
