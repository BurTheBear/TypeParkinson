import SwiftUI

/// Two typing rounds: standard keyboard, then the proposed one.
struct CheckView: View {
    @Environment(AppModel.self) private var model
    @State private var round = 0
    @State private var standard: TypingOutcome?

    var body: some View {
        VStack(spacing: 16) {
            TaskHeader(kicker: "Check · round \(round + 1) of 2",
                       segments: [0, 1].map { $0 <= round ? Theme.accent : Theme.neutral300 },
                       title: round == 0 ? "Type on a standard keyboard" : "Now type on yours",
                       hint: "A fresh phrase each round, so practice doesn’t skew the comparison.")
            TypingTaskView(
                target: round == 0 ? Phrases.standardRound : Phrases.personalRound,
                settings: round == 0 ? nil : model.settings,
                simulation: model.simulator.keyboardSimulation
            ) { outcome in
                if let standard {
                    model.finishCheck(CheckResult(standard: standard, personal: outcome))
                } else {
                    standard = outcome
                    round = 1
                }
            }
            .id(round)
        }
    }
}

struct CompareView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let result = model.checkResult {
            content(result)
        } else {
            Color.clear.onAppear { model.screen = .proposal }
        }
    }

    private func content(_ result: CheckResult) -> some View {
        let base = result.standard.phrase
        let mine = result.personal.phrase
        let verdict = verdict(base, mine)
        return Page {
            Heading(kicker: "Check results", title: verdict.title, subtitle: verdict.detail)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    Text("")
                    Text("Standard").font(Theme.serif(.subheadline, weight: .semibold))
                    Text("Yours").font(Theme.serif(.subheadline, weight: .semibold))
                }
                Divider().gridCellUnsizedAxes(.horizontal)
                metricRow("Errors left", Double(base.errors), Double(mine.errors), "\(base.errors)", "\(mine.errors)")
                metricRow("Corrections", Double(base.corrections), Double(mine.corrections), "\(base.corrections)", "\(mine.corrections)")
                metricRow("Time", base.time, mine.time,
                          String(format: "%.1f s", base.time), String(format: "%.1f s", mine.time))
            }
            .font(Theme.serif(.body))
            .monospacedDigit()

            VStack(alignment: .leading, spacing: 16) {
                Text("What each setting did").font(Theme.serif(.title3, weight: .semibold))
                ForEach(evidence(result)) { item in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(Theme.serif(.body, weight: .semibold))
                            Text(item.text)
                                .font(Theme.serif(.subheadline))
                                .foregroundStyle(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        if let turnOff = item.turnOff {
                            Button("Turn off", action: turnOff).buttonStyle(.secondary(minHeight: 40, fullWidth: false))
                        }
                    }
                    .padding(14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
            }
        } footer: {
            Button("Approve this keyboard") { model.approve() }.buttonStyle(.primary)
            HStack(spacing: 8) {
                Button("Change settings") { model.screen = .proposal }.buttonStyle(.secondary(minHeight: 44))
                Button("Check again") { model.startCheck() }.buttonStyle(.secondary(minHeight: 44))
            }
        }
    }

    private func metricRow(_ name: String, _ base: Double, _ mine: Double, _ baseText: String, _ mineText: String) -> some View {
        GridRow {
            Text(name)
            Text(baseText)
            Text(mineText)
                .fontWeight(.semibold)
                .foregroundStyle(mine < base - 0.05 ? Theme.accent700 : mine > base + 0.05 ? Theme.warning : Theme.text)
        }
    }

    private func verdict(_ base: PhraseResult, _ mine: PhraseResult) -> (title: String, detail: String) {
        let better = [mine.errors < base.errors, mine.corrections < base.corrections, mine.time < base.time].filter { $0 }.count
        let worse = [mine.errors > base.errors, mine.corrections > base.corrections, mine.time > base.time].filter { $0 }.count
        if mine.errors > base.errors {
            return ("Yours didn’t help this time.",
                    "More errors with the personalized keyboard. Turn off a setting below, or change them and check again.")
        }
        if better >= 2 && worse == 0 {
            return ("Your keyboard helped.", "Fewer mistakes than the standard keyboard, on a phrase you hadn’t seen.")
        }
        return ("Mixed results.",
                "Some measures improved and some didn’t. Settings without evidence of helping are marked below.")
    }

    private struct Evidence: Identifiable {
        var name: String
        var text: String
        var turnOff: (() -> Void)?
        var id: String { name }
    }

    private func evidence(_ result: CheckResult) -> [Evidence] {
        let settings = model.settings
        let base = result.standard.phrase, mine = result.personal
        var items = [Evidence(name: "Key size · \(settings.keySize.rawValue)",
                              text: "Errors went from \(base.errors) to \(mine.phrase.errors).")]
        if settings.offsetEnabled {
            let hurt = mine.hurt > 0 ? ", and \(mine.hurt) off it" : ""
            items.append(Evidence(
                name: "Touch interpretation",
                text: "Moved \(mine.corrected) of \(mine.taps) taps onto the key you aimed for\(hurt).",
                turnOff: mine.hurt >= mine.corrected ? { model.settings.offsetEnabled = false } : nil))
        }
        if settings.repeatFilterEnabled {
            let blocked = mine.blockedRepeats
            items.append(Evidence(
                name: "Repeat handling",
                text: blocked > 0 ? "Blocked \(blocked) accidental extra contact\(blocked == 1 ? "" : "s")."
                                  : "No extra contacts happened, so it had nothing to do.",
                turnOff: blocked == 0 ? { model.settings.repeatFilterEnabled = false } : nil))
        }
        if settings.correctionBarEnabled {
            let n = mine.phrase.corrections
            items.append(Evidence(name: "Correction controls",
                                  text: "You made \(n) correction\(n == 1 ? "" : "s") with the keyboard."))
        }
        if settings.toleranceEnabled {
            items.append(Evidence(name: "Tap tolerance", text: "Not measured in this check."))
        }
        return items
    }
}
