import AuthenticationServices
import SwiftUI

enum AppLinks {
    static let privacyPolicy = URL(string: "https://pranav-atreya10.github.io/TypeParkinson/privacy.html")!
    static let support = URL(string: "https://pranav-atreya10.github.io/TypeParkinson/support.html")!
}

/// First launch, after onboarding: sign in with Apple to sync, or carry on without.
struct AccountView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Page {
            Heading(kicker: "Your account",
                    title: "Keep your keyboard on all your devices.",
                    subtitle: "Sign in with Apple to save your touch profile and keyboard to your iCloud. Set it up once, and your other iPhone or iPad picks it up too.")
            VStack(alignment: .leading, spacing: 14) {
                point("No passwords", "Sign in with Apple uses your Apple Account and Face ID or Touch ID.")
                point("Your iCloud, not ours", "TypeParkinson has no servers. Your profile is stored in your own iCloud, where only your devices can read it.")
                point("Optional", "Everything works without an account — your keyboard just stays on this device.")
            }
            FootNote("You can sign in later, sign out, or delete everything at any time in Settings.")
        } footer: {
            AppleSignInButton()
            Button("Continue without an account") { model.continueWithoutAccount() }
                .buttonStyle(.secondary())
            Button("Back") { model.screen = .onboarding }.buttonStyle(.ghost())
        }
    }

    private func point(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(Theme.serif(.body, weight: .semibold))
            Text(text)
                .font(Theme.serif(.subheadline))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct AppleSignInButton: View {
    @Environment(AppModel.self) private var model
    @Environment(\.colorScheme) private var colorScheme
    @State private var errorMessage: String?

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            // Only the name, to greet people; no email address.
            request.requestedScopes = [.fullName]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    model.signedIn(with: credential)
                }
            case .failure(let error):
                // Cancelling, or closing iOS's own "sign in to your Apple Account" prompt,
                // needs no second message.
                let code = (error as? ASAuthorizationError)?.code
                if code != .canceled, code != .unknown {
                    errorMessage = "Sign in with Apple didn’t work. Check that this device is signed in to an Apple Account in Settings, then try again."
                }
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .alert("Couldn’t sign in", isPresented: Binding(get: { errorMessage != nil },
                                                      set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmingDelete = false

    var body: some View {
        Page {
            Heading(kicker: "TypeParkinson", title: "Settings")

            section("Account") {
                if let account = model.account {
                    Text(account.name.map { "Signed in with Apple as \($0)." } ?? "Signed in with Apple.")
                        .font(Theme.serif(.body, weight: .semibold))
                    FootNote(CloudStore.isSyncAvailable
                             ? "Your touch profile and keyboard are saved to your iCloud and kept up to date on your other devices."
                             : "iCloud is off on this device, so your keyboard is only saved here. Turn on iCloud in the Settings app to sync it.")
                    Button("Sign out") { model.signOut() }
                        .buttonStyle(.secondary(minHeight: 44, fullWidth: false))
                    FootNote("Signing out stops syncing. Your keyboard keeps working on this device.")
                } else {
                    FootNote("Sign in with Apple to save your keyboard to iCloud and use it on your other devices.")
                    AppleSignInButton()
                }
            }

            section("Appearance") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Liquid Glass").font(Theme.serif(.body, weight: .semibold))
                    FootNote("Buttons and cards take on the translucent Liquid Glass look instead of the plain, solid one. Off by default for the clearest contrast.")
                    SegmentedChoice(onOff: Binding(
                        get: { model.liquidGlassEnabled },
                        set: { model.liquidGlassEnabled = $0 }))
                }
            }

            section("Keyboard") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hold delete to keep deleting").font(Theme.serif(.body, weight: .semibold))
                    FootNote("Starts after a longer pause than usual, so a slow lift doesn’t erase text. Undo brings back everything from one hold.")
                    SegmentedChoice(onOff: Binding(
                        get: { model.settings.holdToDeleteEnabled },
                        set: { value in model.updateKeyboard { $0.holdToDeleteEnabled = value } }))
                }
                linkRow("Edit keyboard settings") { model.screen = .proposal }
                linkRow("Redo the touch exercises") { model.startExercises() }
                linkRow("Turn on the keyboard") { model.screen = .enable }
            }

            section("About") {
                Link(destination: AppLinks.support) { rowLabel("Help and support", external: true) }
                Link(destination: AppLinks.privacyPolicy) { rowLabel("Privacy policy", external: true) }
                FootNote("TypeParkinson describes how your touches behave. It isn’t a medical device, doesn’t assess or diagnose any condition, and isn’t a substitute for advice from a clinician.")
                Text("Version \(Bundle.main.versionDescription)")
                    .font(Theme.serif(.footnote))
                    .foregroundStyle(Theme.secondaryText)
            }

            section("Your data") {
                FootNote(model.account == nil
                         ? "Your touch profile and keyboard settings are stored on this device only. Nothing you type is ever saved."
                         : "Your touch profile and keyboard settings are stored on this device and in your iCloud. Nothing you type is ever saved.")
                Button(model.account == nil ? "Delete all data" : "Delete account and data", role: .destructive) {
                    confirmingDelete = true
                }
                .buttonStyle(.destructive())
            }

            #if DEBUG
            section("Developer") {
                DemoModeToggle()
            }
            #endif
        } footer: {
            Button("Done") { model.screen = .home }.buttonStyle(.primary)
        }
        .confirmationDialog(model.account == nil ? "Delete all data?" : "Delete your account and data?",
                            isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if model.account == nil { model.deleteLocalData() } else { model.deleteAccountAndData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(model.account == nil
                 ? "Your touch profile and keyboard settings will be removed from this device, and the keyboard goes back to standard settings. This can’t be undone."
                 : "Your touch profile and keyboard settings will be removed from this device and from iCloud, and you’ll be signed out. This can’t be undone. To also remove TypeParkinson from your Apple Account, open Settings › your name › Sign-In & Security › Sign in with Apple.")
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(Theme.serif(.title3, weight: .semibold))
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .overlay(alignment: .top) { Theme.divider.frame(height: 1).offset(y: -12) }
    }

    private func linkRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { rowLabel(title, external: false) }
            .buttonStyle(.plain)
    }

    private func rowLabel(_ title: String, external: Bool) -> some View {
        HStack {
            Text(title).font(Theme.serif(.body))
            Spacer()
            Image(systemName: external ? "arrow.up.right" : "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .foregroundStyle(Theme.text)
    }
}

extension Bundle {
    /// "1.0 (3)"
    var versionDescription: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }
}
