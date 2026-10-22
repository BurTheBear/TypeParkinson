import AuthenticationServices
import SwiftUI
import UIKit

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
            Text(title).font(Theme.font(.body, weight: .semibold))
            Text(text)
                .font(Theme.font(.subheadline))
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
    @State private var editingPhrases = false
    @State private var notificationsOff = false

    var body: some View {
        NavigationStack {
            Form {
                accountSection
                keyboardSection
                appearanceSection
                appLookSection
                reminderSection
                speechSection
                aboutSection
                dataSection
                #if DEBUG
                developerSection
                #endif
            }
            .scrollContentBackground(.hidden)
            .background {
                ZStack(alignment: .top) {
                    Theme.bg.ignoresSafeArea()
                    AuraWash()
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $editingPhrases) { PhraseEditor().environment(model) }
            .alert("Notifications are off", isPresented: $notificationsOff) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Not now", role: .cancel) {}
            } message: {
                Text("To get a daily reminder, allow notifications for TypeParkinson in the Settings app.")
            }
            .confirmationDialog(model.account == nil ? "Delete all data?" : "Delete your account and data?",
                                isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if model.account == nil { model.deleteLocalData() } else { model.deleteAccountAndData() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(model.account == nil
                     ? "Your touch profile, history, phrases and keyboard settings will be removed from this device, and the keyboard goes back to standard settings. This can’t be undone."
                     : "Your touch profile, history, phrases and keyboard settings will be removed from this device and from iCloud, and you’ll be signed out. This can’t be undone. To also remove TypeParkinson from your Apple Account, open Settings › your name › Sign-In & Security › Sign in with Apple.")
            }
        }
    }

    // MARK: Sections

    private var accountSection: some View {
        Section {
            if let account = model.account {
                Label(account.name.map { "Signed in as \($0)" } ?? "Signed in with Apple", systemImage: "person.crop.circle.fill")
                Button("Sign out") { model.signOut() }
            } else {
                AppleSignInButton()
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        } header: {
            Text("Account")
        } footer: {
            Text(model.account == nil
                 ? "Sign in with Apple to keep your keyboard in your iCloud and use it on your other devices."
                 : CloudStore.isSyncAvailable
                    ? "Your touch profile and keyboard are saved to your iCloud and kept up to date on your other devices."
                    : "iCloud is off on this device, so your keyboard is only saved here.")
        }
        .listRowBackground(Theme.card)
    }

    private var keyboardSection: some View {
        Section {
            row("Turn on the keyboard", symbol: "keyboard.badge.ellipsis", color: Theme.accent) { model.screen = .enable }
            row("Edit and re-check key settings", symbol: "slider.horizontal.3", color: Theme.accent) { model.screen = .proposal }
            row("Quick phrases", symbol: "text.bubble.fill", color: Theme.speakColor, detail: "\(model.phrases.count)") { editingPhrases = true }
            toggle("Smart correction", symbol: "wand.and.stars", color: Theme.accent,
                   value: model.settings.smartCorrectionEnabled) { v in model.updateKeyboard { $0.smartCorrectionEnabled = v } }
            toggle("Word suggestions", symbol: "text.word.spacing", color: Theme.accent,
                   value: model.settings.suggestionsEnabled) { v in model.updateKeyboard { $0.suggestionsEnabled = v } }
            toggle("Phrases button", symbol: "text.bubble", color: Theme.speakColor,
                   value: model.settings.phrasesEnabled) { v in model.updateKeyboard { $0.phrasesEnabled = v } }
            toggle("Key pop-up while touching", symbol: "rectangle.and.hand.point.up.left", color: Theme.accent,
                   value: model.settings.keyPreviewEnabled) { v in model.updateKeyboard { $0.keyPreviewEnabled = v } }
            toggle("Ignore brief brushes", symbol: "hand.raised.slash", color: Theme.tappingColor,
                   value: model.settings.brushFilterEnabled) { v in model.updateKeyboard { $0.brushFilterEnabled = v } }
            if model.settings.brushFilterEnabled {
                Picker("Shorter than", selection: Binding(
                    get: { model.settings.brushDuration },
                    set: { v in model.updateKeyboard { $0.brushDuration = v } })) {
                    ForEach(KeyboardSettings.brushDurations, id: \.self) { d in
                        Text("\(Int(d * 1000)) ms").tag(d)
                    }
                }
            }
            toggle("Hold delete to keep deleting", symbol: "delete.left", color: Theme.typingColor,
                   value: model.settings.holdToDeleteEnabled) { v in model.updateKeyboard { $0.holdToDeleteEnabled = v } }
        } header: {
            Text("Keyboard")
        } footer: {
            Text("Smart correction works out each word from where your touches landed, using your touch profile, and keeps learning on your iPhone as you type. Undo always puts back exactly what you typed.")
        }
        .listRowBackground(Theme.card)
    }

    private var appearanceSection: some View {
        Section {
            HStack(spacing: Theme.Space.s2) {
                ForEach(KeyboardTheme.allCases) { theme in
                    let selected = model.settings.theme == theme
                    Button {
                        model.updateKeyboard { $0.theme = theme }
                    } label: {
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                ForEach(["a", "b"], id: \.self) { letter in
                                    Text(letter)
                                        .font(Theme.font(size: 15, weight: .medium))
                                        .frame(width: 24, height: 30)
                                        .background(theme.palette.inputKey, in: RoundedRectangle(cornerRadius: 5))
                                        .foregroundStyle(theme.palette.label)
                                }
                            }
                            .padding(8)
                            .background(theme.palette.background, in: RoundedRectangle(cornerRadius: 10))
                            Text(theme.rawValue)
                                .font(Theme.font(.caption, weight: selected ? .bold : .regular))
                                .foregroundStyle(Theme.text)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selected ? Theme.accent100 : .clear, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Theme.accent : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(theme.rawValue) theme")
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
            toggle("Larger, bolder key labels", symbol: "textformat.size", color: Theme.accent,
                   value: model.settings.largeLabels) { v in model.updateKeyboard { $0.largeLabels = v } }
            KeyboardView(size: model.settings.keySize, theme: model.settings.theme, largeLabels: model.settings.largeLabels)
                .allowsHitTesting(false)
                .padding(6)
                .background(model.settings.theme.palette.background, in: RoundedRectangle(cornerRadius: 12))
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .accessibilityHidden(true)
        } header: {
            Text("Keyboard look")
        } footer: {
            Text(model.settings.theme.summary)
        }
        .listRowBackground(Theme.card)
    }

    private var appLookSection: some View {
        Section {
            toggle("Liquid Glass buttons", symbol: "sparkles", color: Theme.accent,
                   value: model.liquidGlassEnabled) { v in withAnimation { model.liquidGlassEnabled = v } }
        } header: {
            Text("App look")
        } footer: {
            Text("Buttons take on the translucent Liquid Glass look instead of the solid one. Off by default for the clearest contrast.")
        }
        .listRowBackground(Theme.card)
    }

    private var reminderSection: some View {
        Section {
            toggle("Daily check reminder", symbol: "bell.badge", color: Theme.tappingColor, value: model.reminderEnabled) { v in
                Task {
                    let ok = await model.setReminder(enabled: v)
                    if v, !ok { notificationsOff = true }
                }
            }
            if model.reminderEnabled {
                DatePicker("Time", selection: Binding(
                    get: { Calendar.current.date(from: model.reminderTime) ?? .now },
                    set: { date in
                        let time = Calendar.current.dateComponents([.hour, .minute], from: date)
                        Task { await model.setReminder(enabled: true, time: time) }
                    }), displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("Reminder")
        } footer: {
            Text("A gentle nudge each day to do the six-tap check. Tapping it opens the check.")
        }
        .listRowBackground(Theme.card)
    }

    private var speechSection: some View {
        Section("Speak") {
            Picker(selection: Binding(get: { model.speaker.rate }, set: { model.speaker.rate = $0 })) {
                ForEach(Speaker.Rate.allCases) { Text($0.label).tag($0) }
            } label: {
                Label { Text("Voice speed") } icon: { IconBadge(symbol: "speaker.wave.2.fill", color: Theme.speakColor, size: 30) }
            }
        }
        .listRowBackground(Theme.card)
    }

    private var aboutSection: some View {
        Section {
            Link(destination: AppLinks.support) { Label("Help and support", systemImage: "questionmark.circle") }
            Link(destination: AppLinks.privacyPolicy) { Label("Privacy policy", systemImage: "hand.raised") }
            LabeledContent("Version", value: Bundle.main.versionDescription)
        } header: {
            Text("About")
        } footer: {
            Text("TypeParkinson describes how your touches behave. It isn’t a medical device, doesn’t assess or diagnose any condition, and isn’t a substitute for advice from a clinician.")
        }
        .listRowBackground(Theme.card)
    }

    private var dataSection: some View {
        Section {
            Button(model.account == nil ? "Delete all data" : "Delete account and data", role: .destructive) {
                confirmingDelete = true
            }
        } header: {
            Text("Your data")
        } footer: {
            Text("Your touch profile, practice history and phrases are stored on this device\(model.account == nil ? "" : " and in your iCloud"). Nothing you type is ever saved; the keyboard keeps only a few numbers about where your touches land.")
        }
        .listRowBackground(Theme.card)
    }

    #if DEBUG
    private var developerSection: some View {
        Section("Developer") {
            DemoModeToggle()
            Button("Load three weeks of sample history") { model.activity.replace(with: .sample()) }
            Button("Clear practice history", role: .destructive) { model.activity.clear() }
        }
        .listRowBackground(Theme.card)
    }
    #endif

    // MARK: Rows

    private func row(_ title: String, symbol: String, color: Color, detail: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Space.s3) {
                IconBadge(symbol: symbol, color: color, size: 30)
                Text(title).foregroundStyle(Theme.text)
                Spacer()
                if let detail { Text(detail).foregroundStyle(Theme.secondaryText) }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.neutral400)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ title: String, symbol: String, color: Color, value: Bool, set: @escaping (Bool) -> Void) -> some View {
        Toggle(isOn: Binding(get: { value }, set: set)) {
            HStack(spacing: Theme.Space.s3) {
                IconBadge(symbol: symbol, color: color, size: 30)
                Text(title)
            }
        }
        .tint(Theme.accent)
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
