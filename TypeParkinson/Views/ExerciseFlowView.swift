import SwiftUI

enum Exercise: Int, CaseIterable {
    case tap, doubleTap, hold, path, type

    var title: String {
        switch self {
        case .tap: "Tap the highlighted target"
        case .doubleTap: "Tap the same target twice"
        case .hold: "Touch and release"
        case .path: "Follow the path"
        case .type: "Copy a short phrase"
        }
    }

    var hint: String {
        switch self {
        case .tap: "Tap the blue circle each time it appears. Some sit close to others."
        case .doubleTap: "Tap the circle twice at your own pace, like typing a double letter."
        case .hold: "Touch the circle, rest your finger there a moment, then lift."
        case .path: "Start on the blue dot and slide along the grey line to the end."
        case .type: "Type it the way you normally would. Fixing mistakes is fine."
        }
    }
}

/// Header shared by the exercises and the check: kicker, progress segments, title.
struct TaskHeader: View {
    let kicker: String
    let segments: [Color]
    let title: String
    let hint: String
    var onPause: (() -> Void)?
    var onSkip: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Kicker(kicker)
                Spacer()
                if let onPause { Button("Pause", action: onPause).buttonStyle(.ghost(minHeight: 40)) }
                if let onSkip { Button("Skip", action: onSkip).buttonStyle(.ghost(minHeight: 40)) }
            }
            .frame(minHeight: 40)
            HStack(spacing: 4) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: 2).fill(color).frame(height: 3)
                }
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(Theme.serif(.title2, weight: .semibold))
                Text(hint)
                    .font(Theme.serif(.subheadline))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }
}

/// The five setup exercises, or the six-tap "typing feels different today" check.
struct ExerciseFlowView: View {
    let recalibration: Bool
    @Environment(AppModel.self) private var model

    @State private var exercise: Exercise = .tap
    @State private var paused = false
    @State private var skipped: Set<Exercise> = []
    @State private var taps: [TapSample] = []
    @State private var doubleTaps: [DoubleTapSample] = []
    @State private var holds: [HoldSample] = []
    @State private var pathDeviation: Double?
    @State private var phrase: PhraseResult?

    var body: some View {
        VStack(spacing: 16) {
            header
            content
                .id(exercise)
                .allowsHitTesting(!paused)
        }
        .overlay {
            if paused { pauseOverlay }
        }
    }

    @ViewBuilder private var header: some View {
        if recalibration {
            TaskHeader(kicker: "Quick check", segments: [Theme.accent],
                       title: "Tap the highlighted target",
                       hint: "Six taps, using the hand you’re typing with today.",
                       onPause: { paused = true }, onSkip: skip)
        } else {
            TaskHeader(kicker: "Exercise \(exercise.rawValue + 1) of 5",
                       segments: Exercise.allCases.map {
                           $0.rawValue < exercise.rawValue ? Theme.accent
                               : $0 == exercise ? Theme.accent400 : Theme.neutral300
                       },
                       title: exercise.title, hint: exercise.hint,
                       onPause: { paused = true }, onSkip: skip)
        }
    }

    @ViewBuilder private var content: some View {
        let simulator = model.simulator
        switch exercise {
        case .tap:
            TapTargetsExercise(trialCount: recalibration ? 6 : 10, simulator: simulator,
                               samples: $taps, onComplete: next)
                .padding([.horizontal, .bottom], 22)
        case .doubleTap:
            DoubleTapExercise(simulator: simulator, samples: $doubleTaps, onComplete: next)
                .padding([.horizontal, .bottom], 22)
        case .hold:
            HoldExercise(simulator: simulator, samples: $holds, onComplete: next)
                .padding([.horizontal, .bottom], 22)
        case .path:
            PathExercise(simulator: simulator, deviation: $pathDeviation, onComplete: next)
                .padding([.horizontal, .bottom], 22)
        case .type:
            TypingTaskView(target: Phrases.exercise, simulation: simulator.keyboardSimulation) {
                phrase = $0.phrase
                next()
            }
        }
    }

    private var pauseOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Paused").font(Theme.serif(.largeTitle, weight: .semibold))
            Text("Take as long as you need. Nothing you’ve done so far is lost.")
                .font(Theme.serif(.body))
                .padding(.bottom, 8)
            Button("Resume") { paused = false }.buttonStyle(.primary)
            Button("Skip this exercise", action: skip).buttonStyle(.secondary())
            Button(recalibration ? "Back to home" : "Leave setup") { model.leaveSetup() }
                .buttonStyle(.ghost())
        }
        .padding(22)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg)
    }

    private func next() {
        if recalibration {
            model.finishRecalibration(taps)
        } else if let following = Exercise(rawValue: exercise.rawValue + 1) {
            exercise = following
        } else {
            finish()
        }
    }

    private func skip() {
        paused = false
        if recalibration {
            model.leaveSetup()
            return
        }
        skipped.insert(exercise)
        next()
    }

    private func finish() {
        model.finishExercises(TouchProfile(
            hand: model.hand,
            taps: taps.count >= 3 ? taps : [],
            doubleTaps: skipped.contains(.doubleTap) || doubleTaps.isEmpty ? nil : doubleTaps,
            holds: skipped.contains(.hold) || holds.isEmpty ? nil : holds,
            pathDeviation: skipped.contains(.path) ? nil : pathDeviation,
            phrase: skipped.contains(.type) ? nil : phrase
        ))
    }
}
