import SwiftUI

/// The touch-sensitive surface the first four exercises draw in.
struct ExerciseArea<Content: View>: View {
    let progress: String
    let message: String
    var began: (AnyHashable, CGPoint, CGSize) -> Void
    var moved: (AnyHashable, CGPoint, CGSize) -> Void = { _, _, _ in }
    var ended: (AnyHashable, CGPoint, CGSize) -> Void = { _, _, _ in }
    @ViewBuilder let content: (CGSize) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    content(geo.size)
                        .frame(width: geo.size.width, height: geo.size.height)
                    Text(message)
                        .font(Theme.serif(.subheadline))
                        .foregroundStyle(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(14)
                        .accessibilityAddTraits(.updatesFrequently)
                }
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .onTouches(
                    began: { began($0, $1, geo.size) },
                    moved: { moved($0, $1, geo.size) },
                    ended: { ended($0, $1, geo.size) }
                )
            }
            Text(progress)
                .font(Theme.serif(.caption))
                .foregroundStyle(Theme.secondaryText)
        }
    }
}

private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    hypot(a.x - b.x, a.y - b.y)
}

private func displaced(_ p: CGPoint, by v: CGVector) -> CGPoint {
    CGPoint(x: p.x + v.dx, y: p.y + v.dy)
}

private func centre(_ size: CGSize) -> CGPoint {
    CGPoint(x: size.width / 2, y: size.height / 2)
}

private func dotView(_ color: Color, _ radius: CGFloat, at point: CGPoint) -> some View {
    Circle().fill(color).frame(width: radius * 2, height: radius * 2).position(point)
}

private func after(milliseconds: Int, _ action: @escaping () -> Void) {
    Task {
        try? await Task.sleep(for: .milliseconds(milliseconds))
        action()
    }
}

// MARK: 1 · Tap targets

struct TapTrial {
    struct Target {
        var center: CGPoint
        var radius: CGFloat
        var isOn: Bool
    }

    var isCluster: Bool
    var u: Double
    var v: Double
    var onIndex: Int

    /// Single targets alternate with rows of three close ones, one of them highlighted.
    static func make(_ count: Int) -> [TapTrial] {
        (0..<count).map { i in
            TapTrial(isCluster: i % 2 == 1, u: .random(in: 0...1), v: .random(in: 0...1), onIndex: .random(in: 0..<3))
        }
    }

    func targets(in size: CGSize) -> [Target] {
        let y = 60 + v * max(0, size.height - 150)
        if !isCluster {
            return [Target(center: CGPoint(x: 60 + u * max(0, size.width - 120), y: y), radius: 26, isOn: true)]
        }
        let x = 100 + u * max(0, size.width - 200)
        return (0..<3).map { i in
            Target(center: CGPoint(x: x + CGFloat(i - 1) * 36, y: y), radius: 16, isOn: i == onIndex)
        }
    }
}

struct TapTargetsExercise: View {
    let simulator: TremorSimulator
    @Binding var samples: [TapSample]
    let onComplete: () -> Void

    @State private var trials: [TapTrial]
    @State private var current = 0
    @State private var flash: CGPoint?
    @State private var busy = false
    @State private var message = ""

    init(trialCount: Int, simulator: TremorSimulator, samples: Binding<[TapSample]>, onComplete: @escaping () -> Void) {
        self.simulator = simulator
        self._samples = samples
        self.onComplete = onComplete
        self._trials = State(initialValue: TapTrial.make(trialCount))
    }

    var body: some View {
        ExerciseArea(
            progress: "Target \(min(current + 1, trials.count)) of \(trials.count)",
            message: message,
            began: { _, point, size in tap(point, size) }
        ) { size in
            ZStack {
                if current < trials.count {
                    ForEach(Array(trials[current].targets(in: size).enumerated()), id: \.offset) { _, target in
                        dotView(target.isOn ? Theme.accent : Theme.neutral400, target.radius, at: target.center)
                    }
                }
                if let flash {
                    dotView(Theme.warning, 6, at: flash)
                }
            }
        }
    }

    private func tap(_ point: CGPoint, _ size: CGSize) {
        guard !busy, current < trials.count else { return }
        let landed = displaced(point, by: simulator.tapDisplacement())
        let targets = trials[current].targets(in: size)
        guard let aimed = targets.first(where: \.isOn),
              let nearest = targets.min(by: { distance(landed, $0.center) < distance(landed, $1.center) })
        else { return }
        let hit = nearest.isOn && distance(landed, aimed.center) <= aimed.radius + 6
        samples.append(TapSample(isCluster: trials[current].isCluster,
                                 dx: landed.x - aimed.center.x, dy: landed.y - aimed.center.y, hit: hit))
        flash = landed
        busy = true
        message = hit ? "" : "Landed outside the target — that’s useful too."
        after(milliseconds: 450) {
            flash = nil
            busy = false
            if current + 1 >= trials.count {
                onComplete()
            } else {
                current += 1
                message = ""
            }
        }
    }
}

// MARK: 2 · Double tap

struct DoubleTapExercise: View {
    let simulator: TremorSimulator
    @Binding var samples: [DoubleTapSample]
    let onComplete: () -> Void

    /// Contacts closer together than this are counted as accidental, not as the second tap.
    private let bounceWindow: TimeInterval = 0.15

    @State private var contacts = 0
    @State private var deliberateTimes: [TimeInterval] = []
    @State private var lastContact: TimeInterval = 0
    @State private var roundID = UUID()
    @State private var busy = false
    @State private var message = "Tap twice."

    var body: some View {
        ExerciseArea(
            progress: "Round \(min(samples.count + 1, 4)) of 4",
            message: message,
            began: { _, point, size in contact(point, size) }
        ) { size in
            dotView(deliberateTimes.isEmpty ? Theme.accent : Theme.accent600, 56, at: centre(size))
        }
    }

    private func contact(_ point: CGPoint, _ size: CGSize) {
        guard !busy else { return }
        guard distance(point, centre(size)) <= 70 else {
            message = "Tap inside the circle."
            return
        }
        let now = ProcessInfo.processInfo.systemUptime
        if deliberateTimes.isEmpty || now - lastContact >= bounceWindow {
            deliberateTimes.append(now)
        }
        contacts += 1 + (Double.random(in: 0..<1) < simulator.doubleTapExtraContactChance ? 1 : 0)
        lastContact = now

        guard deliberateTimes.count >= 2 else {
            message = "One more tap."
            return
        }
        // Wait for any trailing contacts before scoring the round.
        let id = UUID()
        roundID = id
        after(milliseconds: 600) {
            if roundID == id { finishRound() }
        }
    }

    private func finishRound() {
        let interval = deliberateTimes[1] - deliberateTimes[0]
        let extra = contacts - 2
        samples.append(DoubleTapSample(interval: interval, contacts: contacts))
        message = "\(contacts) contacts registered\(extra > 0 ? " (\(extra) extra)" : "") · \(Int(interval * 1000)) ms apart"
        contacts = 0
        deliberateTimes = []
        if samples.count >= 4 {
            busy = true
            after(milliseconds: 900, onComplete)
        }
    }
}

// MARK: 3 · Touch and release

struct HoldExercise: View {
    let simulator: TremorSimulator
    @Binding var samples: [HoldSample]
    let onComplete: () -> Void

    private struct Hold {
        var id: AnyHashable
        var start: TimeInterval
        var point: CGPoint
        var maxMove: CGFloat = 0
    }

    @State private var hold: Hold?
    @State private var busy = false
    @State private var message = "Touch, hold briefly, release."

    var body: some View {
        ExerciseArea(
            progress: "Round \(min(samples.count + 1, 4)) of 4",
            message: message,
            began: { id, point, size in
                guard !busy, hold == nil else { return }
                guard distance(point, centre(size)) <= 60 else {
                    message = "Touch the circle to begin."
                    return
                }
                hold = Hold(id: id, start: ProcessInfo.processInfo.systemUptime, point: point)
                message = "Holding…"
            },
            moved: { id, point, _ in
                guard var current = hold, current.id == id else { return }
                current.maxMove = max(current.maxMove, distance(point, current.point))
                hold = current
            },
            ended: { id, _, _ in
                guard let current = hold, current.id == id else { return }
                release(current)
            }
        ) { size in
            dotView(hold == nil ? Theme.accent : Theme.accent700, 56, at: centre(size))
        }
    }

    private func release(_ current: Hold) {
        hold = nil
        let duration = ProcessInfo.processInfo.systemUptime - current.start
        let movement = Double(current.maxMove) + simulator.holdExtraMovement()
        samples.append(HoldSample(duration: duration, movement: movement))
        message = "Held \(String(format: "%.2f", duration)) s · finger moved \(movement.points)"
        if samples.count >= 4 {
            busy = true
            after(milliseconds: 900, onComplete)
        }
    }
}

// MARK: 4 · Follow the path

struct PathExercise: View {
    let simulator: TremorSimulator
    @Binding var deviation: Double?
    let onComplete: () -> Void

    @State private var trail: [CGPoint] = []
    @State private var drawing: AnyHashable?
    @State private var busy = false
    @State private var message = ""

    static func path(in size: CGSize) -> [CGPoint] {
        let amplitude = min(120, max(0, size.height / 2 - 50))
        return (0...80).map { i in
            let t = Double(i) / 80
            return CGPoint(x: 40 + t * (size.width - 80), y: size.height / 2 + amplitude * sin(t * .pi * 1.5))
        }
    }

    var body: some View {
        ExerciseArea(
            progress: "One slide, start to end",
            message: message,
            began: { id, point, size in
                guard !busy, drawing == nil, let start = Self.path(in: size).first else { return }
                guard distance(point, start) <= 36 else {
                    message = "Start on the blue dot at the left."
                    return
                }
                drawing = id
                message = ""
                trail = [displaced(point, by: simulator.slideJitter())]
            },
            moved: { id, point, _ in
                guard drawing == id else { return }
                trail.append(displaced(point, by: simulator.slideJitter()))
            },
            ended: { id, _, size in
                guard drawing == id else { return }
                drawing = nil
                finish(Self.path(in: size))
            }
        ) { size in
            let points = Self.path(in: size)
            ZStack {
                polyline(points).stroke(Theme.neutral400, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                polyline(trail).stroke(Theme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                if let start = points.first, let end = points.last {
                    dotView(Theme.accent, 16, at: start)
                    dotView(Theme.neutral600, 16, at: end)
                }
            }
        }
    }

    private func polyline(_ points: [CGPoint]) -> Path {
        Path { $0.addLines(points) }
    }

    private func finish(_ path: [CGPoint]) {
        guard let end = path.last, let last = trail.last, distance(last, end) <= 40 else {
            message = "Not quite to the end — start again from the dot."
            trail = []
            return
        }
        let mean = trail.map { q in Double(path.map { distance($0, q) }.min() ?? 0) }.mean
        deviation = mean
        message = "Stayed within \(mean.points) of the path on average."
        busy = true
        after(milliseconds: 1400, onComplete)
    }
}
