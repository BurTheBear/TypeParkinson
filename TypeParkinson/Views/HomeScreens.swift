import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let settings = model.settings
        let profile = model.profile ?? TouchProfile()
        Page {
            VStack(alignment: .leading, spacing: 8) {
                Kicker("TypeParkinson")
                Text("Your keyboard is ready.").font(Theme.serif(.largeTitle, weight: .semibold))
                HStack(spacing: 8) {
                    Text("Approved")
                        .font(Theme.serif(.caption))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundStyle(Theme.accent700)
                        .background(Theme.accent100, in: RoundedRectangle(cornerRadius: 1.5))
                    Text("\(settings.keySize.rawValue) keys · personalized for your \(handPhrase(profile.hand))")
                        .font(Theme.serif(.footnote))
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Button("Typing feels different today") { model.startRecalibration() }
                    .buttonStyle(TPButtonStyle(minHeight: 72))
                FootNote("A six-tap check. Adjusts how touches are read today — the keys don’t move.")
            }

            if let today = model.todayOffset {
                HStack(spacing: 12) {
                    Text(todayText(today)).font(Theme.serif(.subheadline))
                    Spacer()
                    Button("Use usual") { model.clearToday() }.buttonStyle(.ghost())
                }
                .padding(.leading, 14)
                .background(Theme.accent100, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }

            HStack(spacing: 18) {
                TouchPlot(taps: profile.taps, size: 120, scale: 1.4, dot: 6)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Touch profile").font(Theme.serif(.body, weight: .semibold))
                    Text(directionText(profile.meanOffset).map { "Touches usually land slightly \($0)." }
                         ?? "Touches land close to centre.")
                        .font(Theme.serif(.subheadline))
                        .foregroundStyle(Theme.secondaryText)
                    Button("View profile") { model.viewProfile() }.buttonStyle(.ghost(minHeight: 40))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Keyboard settings").font(Theme.serif(.title3, weight: .semibold))
                ForEach(settingRows(settings), id: \.name) { row in
                    HStack {
                        Text(row.name)
                        Spacer()
                        Text(row.value).foregroundStyle(Theme.secondaryText)
                    }
                    .font(Theme.serif(.subheadline))
                    .padding(.vertical, 6)
                    .overlay(alignment: .bottom) { Theme.divider.frame(height: 1) }
                }
                HStack(spacing: 8) {
                    Button("Edit") { model.screen = .proposal }
                        .buttonStyle(.secondary(minHeight: 44, fullWidth: false))
                    Button("Full recalibration") { model.startExercises() }
                        .buttonStyle(.secondary(minHeight: 44, fullWidth: false))
                }
                .padding(.top, 4)
                Button("Keyboard not showing up?") { model.screen = .enable }.buttonStyle(.ghost())
            }

            FootNote(model.account == nil
                     ? "Your touch profile stays on this device. TypeParkinson doesn’t save what you type."
                     : "Your touch profile is kept on this device and in your iCloud. TypeParkinson doesn’t save what you type.")
        }
    }

    private func handPhrase(_ hand: Hand) -> String {
        hand == .both ? "hands" : hand.rawValue.lowercased()
    }

    private func todayText(_ today: KeyboardSettings.TodayOffset) -> String {
        let direction = directionText(CGVector(dx: today.x, dy: today.y))
        return "Adjusted for today" + (direction.map { ": touches landing \($0)." } ?? ".")
    }

    private func settingRows(_ s: KeyboardSettings) -> [(name: String, value: String)] {
        let offset = s.behavior.offset
        return [
            ("Key size", s.keySize.rawValue),
            ("Touch interpretation", offset == .zero ? "Off"
                : "\(abs(offset.dx).points) \(offset.dx >= 0 ? "left" : "right"), \(abs(offset.dy).points) \(offset.dy >= 0 ? "up" : "down")"),
            ("Repeat handling", s.repeatFilterEnabled ? "120 ms" : "Off"),
            ("Tap tolerance", s.toleranceEnabled ? s.tolerance.points : "Off"),
            ("Correction controls", s.correctionBarEnabled ? "On" : "Off"),
        ]
    }
}

struct RecalResultView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let usual = model.profile?.taps ?? []
        let today = model.todayTaps
        let shiftVector = CGVector(dx: today.meanOffset.dx - usual.meanOffset.dx,
                                   dy: today.meanOffset.dy - usual.meanOffset.dy)
        let shift = hypot(shiftVector.dx, shiftVector.dy)
        let different = shift > 4
        Page {
            Heading(kicker: "Today vs. usual",
                    title: different ? "Today looks a little different." : "Today looks like usual.",
                    subtitle: different
                        ? "Touches are landing about \(shift.points) further \(directionText(shiftVector) ?? "off centre") than usual. TypeParkinson can read touches differently today — the keys stay exactly where they are."
                        : "Your usual settings should work well. You can still adjust for today if typing feels off.")
            HStack(spacing: 20) {
                plot(usual, "Usual", Theme.neutral600)
                plot(today, "Today", Theme.accent)
            }
            .frame(maxWidth: .infinity)
        } footer: {
            Button("Adjust for today") { model.applyToday() }.buttonStyle(.primary)
            Button("Keep my usual settings") { model.screen = .home }.buttonStyle(.secondary())
        }
    }

    private func plot(_ taps: [TapSample], _ label: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            TouchPlot(taps: taps, size: 140, scale: 1.6, dot: 7, color: color)
            Text(label).font(Theme.serif(.footnote)).foregroundStyle(Theme.secondaryText)
        }
    }
}
