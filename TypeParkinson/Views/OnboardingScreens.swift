import SwiftUI

/// First launch: what TypeParkinson does, in four short pages.
struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0

    private let pageCount = 5

    var body: some View {
        Page {
            HStack {
                Kicker("TypeParkinson")
                Spacer()
                if page < pageCount - 1 {
                    Button("Skip") { model.finishOnboarding() }.buttonStyle(.ghost(minHeight: 40))
                }
            }
            .frame(minHeight: 40)
            content
                .id(page)
                .transition(.opacity)
        } footer: {
            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Theme.accent : Theme.neutral300)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 8)
            .accessibilityElement()
            .accessibilityLabel("Page \(page + 1) of \(pageCount)")
            Button(page < pageCount - 1 ? "Next" : "Get started") {
                if page < pageCount - 1 {
                    withAnimation(.easeInOut(duration: 0.2)) { page += 1 }
                } else {
                    model.finishOnboarding()
                }
            }
            .buttonStyle(.primary)
            if page > 0 {
                Button("Back") { withAnimation(.easeInOut(duration: 0.2)) { page -= 1 } }
                    .buttonStyle(.ghost())
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30).onEnded { drag in
                let next = page + (drag.translation.width < 0 ? 1 : -1)
                if abs(drag.translation.width) > abs(drag.translation.height), (0..<pageCount).contains(next) {
                    withAnimation(.easeInOut(duration: 0.2)) { page = next }
                }
            }
        )
    }

    @ViewBuilder private var content: some View {
        switch page {
        case 0:
            Heading(kicker: nil,
                    title: "A keyboard built around your hands.",
                    subtitle: "TypeParkinson watches how you touch the screen, builds a keyboard around it, and then checks — on a phrase you haven’t seen — that the new keyboard actually helps you type.")
            KeyboardView(size: .large, showsCorrectionBar: true)
                .allowsHitTesting(false)
                .padding(8)
                .background(Theme.neutral200, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .accessibilityHidden(true)
        case 1:
            Heading(kicker: "How it works", title: "Measure. Build. Check. Then type anywhere.")
            VStack(alignment: .leading, spacing: 18) {
                step(1, "Measure", "Five short exercises, about three minutes. No right answers — pause or skip any of them.")
                step(2, "Build", "Five settings, each traced to something you did. Change any of them.")
                step(3, "Check", "Type a phrase on a standard keyboard and on yours, and see which one helped.")
                step(4, "Type anywhere", "Turn it on once and use it in every app.")
            }
        case 2:
            Heading(kicker: "Make it yours",
                    title: "Try Liquid Glass.",
                    subtitle: "Buttons and cards can use the translucent Liquid Glass material instead of the plain, solid look. It’s off by default, for the clearest contrast — turn it on here or any time later in Settings.")
            VStack(spacing: 14) {
                Button("Example button") {}.buttonStyle(.primary)
                Button("Another one") {}.buttonStyle(.secondary())
                SegmentedChoice(onOff: Binding(
                    get: { model.liquidGlassEnabled },
                    set: { value in withAnimation { model.liquidGlassEnabled = value } }))
            }
        case 3:
            Heading(kicker: "Every day after",
                    title: "Typing feels different today?",
                    subtitle: "Hands aren’t the same every morning. One button runs a six-tap check and compares today with your usual. If your touches are landing somewhere new, TypeParkinson reads them differently for the day.")
            HStack(spacing: 20) {
                plot(TouchProfile.sample.taps, "Usual", Theme.neutral600)
                plot(TouchProfile.sample.taps.map { TapSample(isCluster: false, dx: $0.dx + 7, dy: $0.dy + 6, hit: false) },
                     "Today", Theme.accent)
            }
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
            FootNote("The keys themselves never move. Once you approve a layout it stays put, so your fingers can learn where everything is.")
        default:
            Heading(kicker: "Privacy",
                    title: "Your touches stay yours.",
                    subtitle: "Your touch profile is kept on your device — and, if you sign in, in your own iCloud. TypeParkinson has no servers. The keyboard never saves what you type and doesn’t ask for Full Access.")
            FootNote("TypeParkinson describes how your touches behave. It isn’t a medical device, doesn’t assess or diagnose any condition, and isn’t a substitute for advice from a clinician.")
        }
    }

    private func step(_ number: Int, _ title: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text("\(number)").font(Theme.serif(.title3, weight: .semibold)).foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.serif(.body, weight: .semibold))
                Text(text)
                    .font(Theme.serif(.subheadline))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func plot(_ taps: [TapSample], _ label: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            TouchPlot(taps: taps, size: 130, scale: 1.6, dot: 7, color: color)
            Text(label).font(Theme.serif(.footnote)).foregroundStyle(Theme.secondaryText)
        }
    }
}
