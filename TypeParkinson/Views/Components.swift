import SwiftUI

/// Scrolling page with the mockup's 22pt margins and an optional pinned footer.
struct Page<Content: View, Footer: View>: View {
    @ViewBuilder var content: Content
    @ViewBuilder var footer: Footer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) { content }
                .padding(22)
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) { footer }
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .background(Theme.bg)
        }
    }
}

extension Page where Footer == EmptyView {
    init(@ViewBuilder content: () -> Content) {
        self.init(content: content, footer: { EmptyView() })
    }
}

struct Kicker: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(Theme.serif(.caption, weight: .semibold))
            .tracking(1)
            .foregroundStyle(Theme.accent700)
    }
}

struct Heading: View {
    let kicker: String?
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let kicker { Kicker(kicker) }
            Text(title)
                .font(Theme.serif(.largeTitle, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(Theme.serif(.body))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct FootNote: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(Theme.serif(.footnote))
            .foregroundStyle(Theme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: Buttons

enum TPButtonKind { case primary, secondary, ghost }

struct TPButtonStyle: ButtonStyle {
    var kind: TPButtonKind = .primary
    var minHeight: CGFloat = 52
    var fullWidth = true

    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, kind: kind, minHeight: minHeight, fullWidth: fullWidth)
    }

    private struct StyledButton: View {
        let configuration: Configuration
        let kind: TPButtonKind
        let minHeight: CGFloat
        let fullWidth: Bool
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(Theme.serif(.body, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, kind == .ghost ? 4 : 16)
                .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: minHeight)
                .foregroundStyle(foreground)
                .background(background, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .overlay {
                    if kind == .secondary {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.divider)
                    }
                }
                .contentShape(Rectangle())
                .opacity(isEnabled ? 1 : 0.45)
        }

        private var foreground: Color {
            switch kind {
            case .primary: Theme.bg
            case .secondary: Theme.text
            case .ghost: Theme.accent
            }
        }

        private var background: Color {
            let pressed = configuration.isPressed
            switch kind {
            case .primary: return pressed ? Theme.accent700 : Theme.accent
            case .secondary: return pressed ? Theme.text.opacity(0.14) : .clear
            case .ghost: return pressed ? Theme.accent.opacity(0.18) : .clear
            }
        }
    }
}

extension ButtonStyle where Self == TPButtonStyle {
    static var primary: TPButtonStyle { TPButtonStyle() }
    static func secondary(minHeight: CGFloat = 48, fullWidth: Bool = true) -> TPButtonStyle {
        TPButtonStyle(kind: .secondary, minHeight: minHeight, fullWidth: fullWidth)
    }
    static func ghost(minHeight: CGFloat = 44) -> TPButtonStyle {
        TPButtonStyle(kind: .ghost, minHeight: minHeight, fullWidth: false)
    }
}

// MARK: Segmented choice

/// The mockup's bordered segmented control.
struct SegmentedChoice<Value: Hashable>: View {
    let options: [(label: String, value: Value)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                if index > 0 { Theme.divider.frame(width: 1) }
                let selected = option.value == selection
                Button { selection = option.value } label: {
                    Text(option.label)
                        .font(Theme.serif(.subheadline))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .foregroundStyle(selected ? Theme.bg : Theme.text)
                        .background(selected ? Theme.accent : .clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.divider))
    }
}

extension SegmentedChoice where Value == Bool {
    init(onOff selection: Binding<Bool>) {
        self.init(options: [("On", true), ("Off", false)], selection: selection)
    }
}

// MARK: Touch plot

/// Where taps landed around the target centre: dots, plus a ring for the average.
struct TouchPlot: View {
    let taps: [TapSample]
    var size: CGFloat = 260
    var scale: CGFloat = 3
    var dot: CGFloat = 10
    /// Colours every dot the same instead of by hit / miss.
    var color: Color?

    var body: some View {
        let centre = size / 2
        let mean = taps.meanOffset
        ZStack {
            Circle().stroke(Theme.divider).frame(width: size * 0.6, height: size * 0.6)
            Theme.divider.frame(width: 1, height: size)
            Theme.divider.frame(width: size, height: 1)
            ForEach(Array(taps.enumerated()), id: \.offset) { _, tap in
                Circle()
                    .fill(color ?? (tap.hit ? Theme.accent : Theme.neutral600))
                    .frame(width: dot, height: dot)
                    .position(clamped(centre + tap.dx * scale, centre + tap.dy * scale))
            }
            if !taps.isEmpty {
                Circle()
                    .stroke(Theme.text, lineWidth: 2)
                    .frame(width: dot + 8, height: dot + 8)
                    .position(clamped(centre + mean.dx * scale, centre + mean.dy * scale))
            }
        }
        .frame(width: size, height: size)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .accessibilityElement()
        .accessibilityLabel("Plot of \(taps.count) touches around the target centre")
    }

    private func clamped(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        let inset = dot / 2
        return CGPoint(x: min(max(x, inset), size - inset), y: min(max(y, inset), size - inset))
    }
}

struct PlotLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            item(Circle().fill(Theme.accent), "On target")
            item(Circle().fill(Theme.neutral600), "Missed")
            item(Circle().stroke(Theme.text, lineWidth: 2), "Average")
        }
        .font(Theme.serif(.caption))
        .foregroundStyle(Theme.secondaryText)
    }

    private func item(_ swatch: some View, _ label: String) -> some View {
        HStack(spacing: 6) {
            swatch.frame(width: 10, height: 10)
            Text(label)
        }
    }
}

// MARK: Touch capture

extension View {
    /// Reports each finger's down / move / up separately, so extra contacts are visible.
    func onTouches(
        began: @escaping (AnyHashable, CGPoint) -> Void,
        moved: @escaping (AnyHashable, CGPoint) -> Void = { _, _ in },
        ended: @escaping (AnyHashable, CGPoint) -> Void = { _, _ in }
    ) -> some View {
        modifier(TouchCapture(began: began, moved: moved, ended: ended))
    }
}

private struct TouchCapture: ViewModifier {
    let began: (AnyHashable, CGPoint) -> Void
    let moved: (AnyHashable, CGPoint) -> Void
    let ended: (AnyHashable, CGPoint) -> Void
    @State private var active: Set<AnyHashable> = []

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .gesture(SpatialEventGesture().onChanged(handle).onEnded(handle))
    }

    private func handle(_ events: SpatialEventCollection) {
        for event in events {
            let id = AnyHashable(event.id)
            switch event.phase {
            case .active:
                if active.insert(id).inserted { began(id, event.location) } else { moved(id, event.location) }
            case .ended, .cancelled:
                if active.remove(id) != nil { ended(id, event.location) }
            @unknown default:
                break
            }
        }
    }
}
