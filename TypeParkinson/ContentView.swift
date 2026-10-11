import SwiftUI

struct ContentView: View {
    @State private var model = AppModel()

    var body: some View {
        screen
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.bg.ignoresSafeArea())
            .foregroundStyle(Theme.text)
            .tint(Theme.accent)
            .environment(model)
            .animation(.easeInOut(duration: 0.2), value: model.screen)
    }

    @ViewBuilder private var screen: some View {
        switch model.screen {
        case .onboarding: OnboardingView()
        case .signUp: SignUpView()
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
        }
    }
}

#Preview {
    ContentView()
}
