import CoreGraphics
import Foundation
import Testing
@testable import TypeParkinson

@Suite struct KeyboardLayoutTests {
    private let width: CGFloat = 382

    private func characters(_ layout: KeyboardLayout) -> Set<String> {
        Set(layout.keys.compactMap { if case .character(let c) = $0.action { c } else { nil } })
    }

    @Test func lettersHaveEveryLetterAndSystemKeys() {
        let layout = KeyboardLayout(size: .standard, width: width, options: .init(systemKeys: true))
        #expect(characters(layout).isSuperset(of: Set("abcdefghijklmnopqrstuvwxyz".map(String.init))))
        let actions = layout.keys.map(\.action)
        for action in [KeyAction.shift, .backspace, .space, .returnKey, .nextKeyboard, .mode(.numbers)] {
            #expect(actions.contains(action), "missing \(action)")
        }
    }

    @Test func numbersAndSymbolsLayersCoverDigitsAndPunctuation() {
        let numbers = KeyboardLayout(size: .standard, width: width, options: .init(systemKeys: true, mode: .numbers))
        #expect(characters(numbers).isSuperset(of: Set("0123456789-/:;()$&@\".,?!'".map(String.init))))
        let symbols = KeyboardLayout(size: .standard, width: width, options: .init(systemKeys: true, mode: .symbols))
        #expect(characters(symbols).isSuperset(of: Set("[]{}#%^*+=_\\|~<>".map(String.init))))
        #expect(numbers.keys.contains { $0.action == .mode(.letters) })
        #expect(symbols.keys.contains { $0.action == .mode(.numbers) })
    }

    @Test(arguments: [KeyboardMode.letters, .numbers, .symbols, .numberPad], [true, false])
    func keysStayInsideTheKeyboardWithoutOverlapping(mode: KeyboardMode, globe: Bool) {
        let layout = KeyboardLayout(size: .large, width: width,
                                    options: .init(systemKeys: true, mode: mode, showsGlobe: globe, numberPadExtra: "."))
        let bounds = CGRect(x: 0, y: 0, width: width, height: layout.height)
        for key in layout.keys {
            #expect(bounds.insetBy(dx: -0.5, dy: -0.5).contains(key.frame), "\(key.id) outside")
            #expect(key.frame.width > 20, "\(key.id) too narrow")
        }
        for (i, a) in layout.keys.enumerated() {
            for b in layout.keys[(i + 1)...] {
                #expect(!a.frame.insetBy(dx: 0.5, dy: 0.5).intersects(b.frame), "\(a.id) overlaps \(b.id)")
            }
        }
        #expect(Set(layout.keys.map(\.id)).count == layout.keys.count, "duplicate key ids")
        #expect(layout.keys.contains { $0.action == .nextKeyboard } == globe)
    }

    @Test func numberPadHasDigitsAndTheRightExtraKey() {
        let decimal = KeyboardLayout(size: .standard, width: width,
                                     options: .init(systemKeys: true, mode: .numberPad, numberPadExtra: "."))
        #expect(characters(decimal) == Set("0123456789.".map(String.init)))
        let plain = KeyboardLayout(size: .standard, width: width, options: .init(systemKeys: true, mode: .numberPad))
        #expect(characters(plain) == Set("0123456789".map(String.init)))
    }

    @Test func punctuationKeyFollowsTheField() {
        let email = KeyboardLayout(size: .standard, width: width, options: .init(systemKeys: true, punctuation: "@"))
        #expect(email.keys.contains { $0.action == .character("@") })
    }

    @Test func touchesInGapsGoToTheNearestKey() {
        let layout = KeyboardLayout(size: .standard, width: width, options: .init())
        let q = layout.keys.first { $0.id == "q" }!
        let w = layout.keys.first { $0.id == "w" }!
        #expect(layout.key(at: CGPoint(x: q.frame.midX, y: q.frame.midY))?.id == "q")
        // Just right of q, inside the gap: still q.
        #expect(layout.key(at: CGPoint(x: q.frame.maxX + 1, y: q.frame.midY))?.id == "q")
        #expect(layout.key(at: CGPoint(x: w.frame.minX - 1, y: w.frame.midY))?.id == "w")
        #expect(layout.key(at: CGPoint(x: width / 2, y: layout.height + 100)) == nil)
    }

    @Test func compactRowsAreShorter() {
        #expect(KeySize.large.keyboardHeight(compact: true) < KeySize.large.keyboardHeight(compact: false))
        let compact = KeyboardLayout(size: .large, width: width, options: .init(compact: true))
        #expect(compact.height == KeySize.large.keyboardHeight(compact: true))
        let bottom = compact.keys.first { $0.id == " " }!
        #expect(compact.key(at: CGPoint(x: bottom.frame.midX, y: bottom.frame.midY))?.id == " ")
    }
}

@Suite struct KeyTouchInterpreterTests {
    private let layout = KeyboardLayout(size: .standard, width: 382, options: .init())
    private func key(_ id: String) -> Key { layout.keys.first { $0.id == id }! }

    private func tap(_ interpreter: KeyTouchInterpreter, at point: CGPoint, down: TimeInterval, up: TimeInterval,
                     behavior: KeyboardBehavior, id: Int = 0) -> KeyTouchInterpreter.Outcome {
        interpreter.began(id, at: point, time: down)
        return interpreter.ended(id, at: point, time: up, layout: layout, behavior: behavior)
    }

    private func pressed(_ outcome: KeyTouchInterpreter.Outcome) -> String? {
        if case .press(let press) = outcome { press.key.id } else { nil }
    }

    @Test func offsetReadsATouchWhereItWasAimed() {
        let g = key("g"), h = key("h")
        let landed = CGPoint(x: h.frame.midX, y: h.frame.midY)
        let offset = CGVector(dx: h.frame.midX - g.frame.midX, dy: 0)
        let outcome = tap(KeyTouchInterpreter(), at: landed, down: 0, up: 0.1,
                          behavior: KeyboardBehavior(offset: offset))
        #expect(pressed(outcome) == "g")
        if case .press(let press) = outcome { #expect(press.uncorrectedKey?.id == "h") }
    }

    @Test func quickSecondContactOnTheSameKeyIsIgnored() {
        let interpreter = KeyTouchInterpreter()
        let behavior = KeyboardBehavior(repeatWindow: 0.12)
        let p = CGPoint(x: key("e").frame.midX, y: key("e").frame.midY)
        #expect(pressed(tap(interpreter, at: p, down: 0, up: 0.10, behavior: behavior)) == "e")
        guard case .blockedRepeat = tap(interpreter, at: p, down: 0.15, up: 0.18, behavior: behavior, id: 1) else {
            Issue.record("expected the bounce to be blocked")
            return
        }
    }

    @Test func deliberateDoubleLettersStillType() {
        let interpreter = KeyTouchInterpreter()
        let behavior = KeyboardBehavior(repeatWindow: 0.12)
        let p = CGPoint(x: key("o").frame.midX, y: key("o").frame.midY)
        #expect(pressed(tap(interpreter, at: p, down: 0, up: 0.10, behavior: behavior)) == "o")
        #expect(pressed(tap(interpreter, at: p, down: 0.40, up: 0.50, behavior: behavior, id: 1)) == "o")
    }

    @Test func toleranceKeepsTheFirstKeyWhenTheFingerDrifts() {
        let a = key("a"), s = key("s")
        let down = CGPoint(x: a.frame.midX, y: a.frame.midY)
        let up = CGPoint(x: s.frame.minX + 2, y: s.frame.midY)
        let drift = up.x - down.x

        let tolerant = KeyTouchInterpreter()
        tolerant.began(0, at: down, time: 0)
        #expect(pressed(tolerant.ended(0, at: up, time: 0.2, layout: layout,
                                       behavior: KeyboardBehavior(tolerance: drift + 2))) == "a")

        let strict = KeyTouchInterpreter()
        strict.began(0, at: down, time: 0)
        #expect(pressed(strict.ended(0, at: up, time: 0.2, layout: layout, behavior: .standard)) == "s")
    }
}

@Suite struct KeyboardSettingsTests {
    @Test func olderSavedSettingsStillLoadWithDefaultsForNewFields() throws {
        let json = #"{"keySize":"Large","offsetEnabled":true,"offsetX":4,"offsetY":3,"repeatFilterEnabled":true,"toleranceEnabled":false,"tolerance":14,"correctionBarEnabled":false}"#
        let settings = try JSONDecoder().decode(KeyboardSettings.self, from: Data(json.utf8))
        #expect(settings.keySize == .large)
        #expect(settings.offsetEnabled)
        #expect(!settings.correctionBarEnabled)
        #expect(settings.holdToDeleteEnabled)
        #expect(settings.todayOffset == nil)
    }

    @Test func roundTrips() throws {
        var settings = KeyboardSettings()
        settings.keySize = .extraLarge
        settings.holdToDeleteEnabled = false
        settings.todayOffset = .init(x: 2, y: 5, date: .now)
        let decoded = try JSONDecoder().decode(KeyboardSettings.self, from: JSONEncoder().encode(settings))
        #expect(decoded == settings)
    }

    @Test func todaysOffsetAppliesEvenWhenUsualCorrectionIsOff() {
        var settings = KeyboardSettings()
        settings.offsetEnabled = false
        #expect(settings.behavior.offset == .zero)
        settings.todayOffset = .init(x: 6, y: 4, date: .now)
        #expect(settings.behavior.offset == CGVector(dx: 6, dy: 4))
        settings.todayOffset = .init(x: 6, y: 4, date: .now.addingTimeInterval(-3 * 86_400))
        #expect(settings.behavior.offset == .zero)
    }

    @Test func snapshotRoundTrips() throws {
        let snapshot = CloudSnapshot(profile: .sample, settings: TouchProfile.sample.proposedSettings(),
                                     isSetupComplete: true, modified: Date(timeIntervalSince1970: 1_800_000_000))
        let decoded = try JSONDecoder().decode(CloudSnapshot.self, from: JSONEncoder().encode(snapshot))
        #expect(decoded == snapshot)
        // Comfortably inside iCloud key-value storage's 1 MB limit.
        #expect(try JSONEncoder().encode(snapshot).count < 16_000)
    }
}

@Suite struct TouchProfileTests {
    @Test func sampleProfileProposesHelpfulSettings() {
        let settings = TouchProfile.sample.proposedSettings()
        #expect(settings.keySize == .large)
        #expect(settings.offsetEnabled)
        #expect(settings.repeatFilterEnabled)
        #expect(settings.correctionBarEnabled)
    }

    @Test func accurateTapsKeepStandardKeys() {
        let taps = (0..<10).map { TapSample(isCluster: $0 % 2 == 0, dx: 0.5, dy: -0.5, hit: true) }
        let settings = TouchProfile(taps: taps, doubleTaps: [.init(interval: 0.3, contacts: 2)]).proposedSettings()
        #expect(settings.keySize == .standard)
        #expect(!settings.offsetEnabled)
        #expect(!settings.repeatFilterEnabled)
    }

    @Test func skippedExercisesStillGiveAFinding() {
        #expect(TouchProfile().findings.count == 1)
    }

    @Test func directionText() {
        #expect(TypeParkinson.directionText(CGVector(dx: 6, dy: 5)) == "low and to the right")
        #expect(TypeParkinson.directionText(CGVector(dx: 1, dy: -1)) == nil)
    }
}
