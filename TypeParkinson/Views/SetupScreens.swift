import SwiftUI

struct WelcomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        Page {
            Heading(kicker: "Setup",
                    title: "Let’s learn how you touch the screen.",
                    subtitle: "Five short exercises, about three minutes. There are no right answers — the keyboard adapts to whatever you do.")
            VStack(alignment: .leading, spacing: 10) {
                Text("Hold the phone the way you usually do. Which hand will you tap with?")
                    .font(Theme.font(.subheadline, weight: .semibold))
                SegmentedChoice(options: Hand.allCases.map { ($0.rawValue, $0) }, selection: $model.hand)
            }
            Card(spacing: 0) {
                ForEach(Array(Exercise.allCases.enumerated()), id: \.offset) { index, exercise in
                    HStack(spacing: Theme.Space.s3) {
                        IconBadge(symbol: exercise.symbol, color: exercise.color, size: 38)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(exercise.title).font(Theme.font(.subheadline, weight: .semibold))
                            Text(exercise.measures).font(Theme.font(.caption)).foregroundStyle(Theme.secondaryText)
                        }
                        Spacer(minLength: 0)
                        Text("\(index + 1)")
                            .font(Theme.rounded(.subheadline, weight: .heavy))
                            .foregroundStyle(Theme.neutral400)
                    }
                    .padding(.vertical, 10)
                    if index < Exercise.allCases.count - 1 { Divider().padding(.leading, 50) }
                }
            }
            DemoModeToggle()
        } footer: {
            FootNote("You can pause or skip any exercise. Your touch profile stays on your device.")
            Button("Start exercises") { model.startExercises() }.buttonStyle(.primary)
        }
    }
}

/// Debug builds only: simulated tremor, since simulator clicks are too precise.
struct DemoModeToggle: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        #if DEBUG
        @Bindable var model = model
        Toggle(isOn: $model.simulateTremor) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Simulate tremor (demo)").font(Theme.font(.subheadline, weight: .semibold))
                Text("Adds a simulated offset, jitter and occasional extra contact to every touch in the exercises and checks.")
                    .font(Theme.font(.caption))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .tint(Theme.accent)
        #endif
    }
}

struct ProfileView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let profile = model.profile ?? TouchProfile()
        Page {
            Heading(kicker: "Your touch profile", title: "Here’s how your touches landed.")
            VStack(spacing: 12) {
                TouchPlot(taps: profile.taps)
                PlotLegend()
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 16) {
                ForEach(profile.findings, id: \.self) { finding in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(finding.text).font(Theme.font(.body, weight: .semibold))
                        Text(finding.detail)
                            .font(Theme.font(.subheadline))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            if let estimate = model.patternEstimate, estimate.evidence >= 2 {
                PatternCard(estimate: estimate)
            }
            FootNote("These describe how your touches behaved today. They aren’t a medical assessment and say nothing about any condition.")
        } footer: {
            if model.isViewingSavedProfile {
                Button("Back to home") { model.screen = .home }.buttonStyle(.primary)
            } else {
                Button("See your proposed keyboard") { model.screen = .proposal }.buttonStyle(.primary)
            }
        }
    }
}

struct ProposalView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        let settings = model.settings
        let profile = model.profile ?? TouchProfile()
        let offset = settings.currentOffset
        Page {
            Heading(kicker: "Proposed keyboard",
                    title: "Built from your profile.",
                    subtitle: "Change anything, then try it. Once you approve, the keys stay where they are so your hands can learn them.")

            KeyboardView(size: settings.keySize, behavior: settings.behavior,
                         showsCorrectionBar: settings.correctionBarEnabled)
                .allowsHitTesting(false)
                .padding(8)
                .background(Theme.neutral200, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 24) {
                SettingRow(name: "Key size and spacing",
                           basis: profile.taps.isEmpty ? "No tap data" : "\(profile.clusterHitRate.percent) close-target accuracy",
                           description: "\(settings.keySize.rawValue) keys, \(Int(settings.keySize.gap)) pt apart. Bigger keys trade space on screen for fewer near-misses.") {
                    SegmentedChoice(options: KeySize.allCases.map { ($0.rawValue, $0) }, selection: $model.settings.keySize)
                }
                SettingRow(name: "Touch interpretation", basis: "From target taps",
                           description: "Reads each touch \(abs(offset.dx).points) \(offset.dx >= 0 ? "left" : "right") and \(abs(offset.dy).points) \(offset.dy >= 0 ? "up" : "down") of where it lands, to match where you aim.") {
                    SegmentedChoice(onOff: $model.settings.offsetEnabled)
                }
                SettingRow(name: "Repeat handling", basis: "From double taps",
                           description: "Ignores a second contact on the same key within 120 ms. Deliberate double letters still type.") {
                    SegmentedChoice(onOff: $model.settings.repeatFilterEnabled)
                }
                SettingRow(name: "Tap tolerance", basis: "From touch and release",
                           description: "Keeps the key you first touched if your finger drifts up to \(settings.tolerance.points) before lifting.") {
                    SegmentedChoice(onOff: $model.settings.toleranceEnabled)
                }
                SettingRow(name: "Smart correction", basis: settings.pattern.map { "For \($0.name.lowercased())" } ?? "From your taps",
                           description: "Works out each word from where your touches landed and fixes it when it’s sure. Undo puts back exactly what you typed.") {
                    SegmentedChoice(onOff: $model.settings.smartCorrectionEnabled)
                }
                SettingRow(name: "Ignore brief brushes", basis: "From double taps",
                           description: "Ignores touches that lift in under \(Int(settings.brushDuration * 1000)) ms: a finger brushing past a key on the way to another.") {
                    SegmentedChoice(onOff: $model.settings.brushFilterEnabled)
                }
                SettingRow(name: "Correction controls", basis: "From phrase copying",
                           description: "Large Undo, Delete word and Backspace buttons above the keys.") {
                    SegmentedChoice(onOff: $model.settings.correctionBarEnabled)
                }
            }
        } footer: {
            Button("Try it — compare with a standard keyboard") { model.startCheck() }.buttonStyle(.primary)
            if model.isSetupComplete {
                Button("Cancel") { model.cancelEditing() }.buttonStyle(.ghost())
            }
        }
    }
}

private struct SettingRow<Control: View>: View {
    let name: String
    let basis: String
    let description: String
    @ViewBuilder let control: Control

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(name).font(Theme.font(.body, weight: .semibold))
                Spacer()
                Text(basis).font(Theme.font(.caption)).foregroundStyle(Theme.secondaryText)
            }
            Text(description)
                .font(Theme.font(.subheadline))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            control
        }
    }
}
