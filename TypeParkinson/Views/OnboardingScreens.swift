import SwiftUI

/// First launch: what TypeParkinson does, in six pages over the Aura.
struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0

    private let pageCount = 6

    var body: some View {
        ZStack {
            AuraBackground(mood: page == 2 ? .calm : page == 5 ? .calm : .neutral)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("TypeParkinson")
                        .font(Theme.rounded(.headline, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                    if page < pageCount - 1 {
                        Button("Skip") { model.finishOnboarding() }
                            .buttonStyle(GlassPillButtonStyle(minHeight: 40))
                    }
                }
                .padding(.horizontal, Theme.Space.s5)
                .padding(.top, Theme.Space.s2)

                TabView(selection: $page) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        ScrollView {
                            pageContent(index)
                                .padding(.horizontal, Theme.Space.s5)
                                .padding(.top, Theme.Space.s6)
                                .frame(maxWidth: 560)
                                .frame(maxWidth: .infinity)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: Theme.Space.s4) {
                    HStack(spacing: 8) {
                        ForEach(0..<pageCount, id: \.self) { index in
                            Capsule()
                                .fill(.white.opacity(index == page ? 1 : 0.35))
                                .frame(width: index == page ? 22 : 8, height: 8)
                        }
                    }
                    .animation(.spring(duration: 0.3), value: page)
                    .accessibilityElement()
                    .accessibilityLabel("Page \(page + 1) of \(pageCount)")
                    Button {
                        if page < pageCount - 1 {
                            withAnimation(.smooth(duration: 0.35)) { page += 1 }
                        } else {
                            model.finishOnboarding()
                        }
                    } label: {
                        Text(page < pageCount - 1 ? "Next" : "Get started")
                    }
                    .buttonStyle(AuraPrimaryButtonStyle())
                }
                .padding(.horizontal, Theme.Space.s5)
                .padding(.bottom, Theme.Space.s4)
            }
        }
        .environment(\.colorScheme, .dark)
        .sensoryFeedback(.selection, trigger: page)
    }

    @ViewBuilder private func pageContent(_ index: Int) -> some View {
        switch index {
        case 0:
            OnboardingPage(title: "A keyboard that learns your hands.",
                           body: "TypeParkinson measures how you touch the screen, builds a keyboard around it, and proves it helps before you use it anywhere.") {
                KeyboardView(size: .large, showsCorrectionBar: true, theme: .classic)
                    .allowsHitTesting(false)
                    .padding(8)
                    .background(KeyboardTheme.classic.palette.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .environment(\.colorScheme, .light)
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    .accessibilityHidden(true)
            }
        case 1:
            OnboardingPage(title: "It works out what you meant.",
                           body: "When a shaky tap lands on the wrong key, smart correction reads where your finger actually was and fixes the word. It keeps learning, on your iPhone, every time you type.") {
                VStack(spacing: Theme.Space.s3) {
                    correctionRow("tje", "the")
                    correctionRow("hellloo", "hello")
                    correctionRow("tomorow", "tomorrow")
                }
            }
        case 2:
            OnboardingPage(title: "See how your hands are doing.",
                           body: "A 30-second daily check, plus a spiral, rhythm tapping, a tremor meter that uses your phone’s motion sensors, and a voice exercise. Progress shows the trends.") {
                HStack(spacing: Theme.Space.s4) {
                    DailyRings(rings: [
                        .init(id: "Check", progress: 1, color: Color(rgb: 0x5C8BFF)),
                        .init(id: "Practice", progress: 0.7, color: Color(rgb: 0x2BE0C8)),
                        .init(id: "Voice", progress: 0.45, color: Color(rgb: 0xFFC94D)),
                    ], lineWidth: 14, gap: 5)
                    .frame(width: 130, height: 130)
                    VStack(alignment: .leading, spacing: 10) {
                        feature("hand.tap.fill", "Daily check")
                        feature("hurricane", "Spiral")
                        feature("waveform.path.ecg", "Tremor meter")
                        feature("mic.fill", "Voice volume")
                    }
                }
                .frame(maxWidth: .infinity)
            }
        case 3:
            OnboardingPage(title: "Speak, show and remember.",
                           body: "Type something and have it read aloud. Show a big card when you need patience. Log your medication and find the hours your hands are steadiest.") {
                HStack(spacing: Theme.Space.s3) {
                    bubble("speaker.wave.2.fill", "Speak", Theme.speakColor)
                    bubble("rectangle.portrait.on.rectangle.portrait.fill", "Show card", Theme.typingColor)
                    bubble("pills.fill", "Medication", Theme.medsColor)
                }
            }
        case 4:
            OnboardingPage(title: "Try Liquid Glass.",
                           body: "Buttons can use the translucent Liquid Glass material instead of the solid look. It’s off by default, for the clearest contrast. Turn it on here or any time later in Settings.") {
                VStack(spacing: Theme.Space.s3) {
                    Button("Example button") {}.buttonStyle(.primary)
                    Button("Another one") {}.buttonStyle(.secondary())
                    SegmentedChoice(onOff: Binding(
                        get: { model.liquidGlassEnabled },
                        set: { value in withAnimation { model.liquidGlassEnabled = value } }))
                }
            }
        default:
            OnboardingPage(title: "Your touches stay yours.",
                           body: "Everything is measured on your iPhone and kept there, or in your own iCloud if you sign in. There are no TypeParkinson servers, and the keyboard never saves what you type.") {
                VStack(alignment: .leading, spacing: Theme.Space.s3) {
                    feature("lock.fill", "No accounts required, no servers")
                    feature("keyboard.badge.eye", "Works without Full Access")
                    feature("stethoscope", "Not a medical device: it describes your touches and doesn’t diagnose")
                }
            }
        }
    }

    private func correctionRow(_ typed: String, _ fixed: String) -> some View {
        HStack(spacing: Theme.Space.s3) {
            Text(typed)
                .strikethrough(color: .white.opacity(0.6))
                .font(Theme.rounded(.title3, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
                .frame(maxWidth: .infinity, alignment: .trailing)
            Image(systemName: "arrow.right")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            Text(fixed)
                .font(Theme.rounded(.title3, weight: .heavy))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, Theme.Space.s4)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func feature(_ symbol: String, _ text: String) -> some View {
        Label {
            Text(text).font(Theme.font(.subheadline, weight: .semibold)).foregroundStyle(.white)
        } icon: {
            Image(systemName: symbol).foregroundStyle(.white.opacity(0.85))
        }
    }

    private func bubble(_ symbol: String, _ title: String, _ color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(color.gradient, in: Circle())
                .shadow(color: color.opacity(0.5), radius: 10, y: 4)
            Text(title).font(Theme.font(.caption, weight: .semibold)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Space.s4)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

/// One onboarding page: a big headline, a sentence, and a picture of the feature.
private struct OnboardingPage<Art: View>: View {
    let title: String
    let body_: String
    @ViewBuilder var art: Art

    init(title: String, body: String, @ViewBuilder art: () -> Art) {
        self.title = title
        self.body_ = body
        self.art = art()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.s6) {
            art
            VStack(alignment: .leading, spacing: Theme.Space.s3) {
                Text(title)
                    .font(Theme.rounded(size: 34, weight: .heavy))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(body_)
                    .font(Theme.font(.body))
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
