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
        .background {
            ZStack(alignment: .top) {
                Theme.bg.ignoresSafeArea()
                AuraWash(height: 280)
            }
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

            HStack(spacing: Theme.Space.s3) {
                metricTile("Errors", base: Double(base.errors), mine: Double(mine.errors), decimals: 0, unit: nil)
                metricTile("Fixes", base: Double(base.corrections), mine: Double(mine.corrections), decimals: 0, unit: nil)
                metricTile("Seconds", base: base.time, mine: mine.time, decimals: 1, unit: nil)
            }
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                Text("What each setting did").font(Theme.rounded(.title3, weight: .bold))
                ForEach(evidence(result)) { item in
                    HStack(alignment: .top, spacing: Theme.Space.s3) {
                        IconBadge(symbol: symbol(for: item.name), color: Theme.accent, size: 38)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(Theme.font(.body, weight: .semibold))
                            Text(item.text)
                                .font(Theme.font(.subheadline))
                                .foregroundStyle(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                        if let turnOff = item.turnOff {
                            Button("Turn off", action: turnOff).buttonStyle(.secondary(minHeight: 40, fullWidth: false))
                        }
                    }
                    .padding(Theme.Space.s4)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
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

    /// Yours in big type, the standard keyboard underneath, and an arrow when yours did better or worse.
    private func metricTile(_ name: String, base: Double, mine: Double, decimals: Int, unit: String?) -> some View {
        let better = mine < base - 0.05, worse = mine > base + 0.05
        let format: (Double) -> String = { $0.formatted(.number.precision(.fractionLength(decimals))) + (unit.map { " \($0)" } ?? "") }
        return VStack(alignment: .leading, spacing: 4) {
            Text(name.uppercased())
                .font(Theme.font(.caption2, weight: .heavy))
                .tracking(0.5)
                .lineLimit(1)
                .foregroundStyle(Theme.secondaryText)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(format(mine))
                    .font(Theme.rounded(.title, weight: .heavy))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(better ? Theme.positive : worse ? Theme.warning : Theme.text)
                if better || worse {
                    Image(systemName: better ? "arrow.down" : "arrow.up")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(better ? Theme.positive : Theme.warning)
                }
            }
            Text("Standard \(format(base))")
                .font(Theme.font(.caption))
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(Theme.Space.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name): yours \(format(mine)), standard \(format(base))")
    }

    private func symbol(for setting: String) -> String {
        switch setting {
        case let s where s.hasPrefix("Key size"): "keyboard"
        case "Touch interpretation": "scope"
        case "Repeat handling": "repeat"
        case "Smart correction": "wand.and.stars"
        case "Brush filter": "hand.raised.slash"
        case "Correction controls": "arrow.uturn.backward"
        default: "hand.point.up.left"
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
        if settings.smartCorrectionEnabled {
            let fixed = mine.autoCorrected
            items.append(Evidence(
                name: "Smart correction",
                text: fixed > 0 ? "Worked out and fixed \(fixed) word\(fixed == 1 ? "" : "s") from where your touches landed."
                                : "Every word came out as you meant it, so it had nothing to fix."))
        }
        if settings.brushFilterEnabled {
            let ignored = mine.ignoredBrushes
            items.append(Evidence(
                name: "Brush filter",
                text: ignored > 0 ? "Ignored \(ignored) brief brush\(ignored == 1 ? "" : "es") that would have typed a stray letter."
                                  : "No brief brushes happened this time.",
                turnOff: ignored == 0 && mine.phrase.errors > result.standard.phrase.errors ? { model.settings.brushFilterEnabled = false } : nil))
        }
        if settings.toleranceEnabled {
            items.append(Evidence(name: "Tap tolerance", text: "Not measured in this check."))
        }
        return items
    }
}
