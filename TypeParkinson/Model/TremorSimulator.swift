import CoreGraphics
import Foundation

/// Mouse clicks in the simulator are too precise to show much, so in demo mode
/// every touch passes through a simulated offset, jitter and occasional extra
/// contact — the same model the mockup uses.
struct TremorSimulator {
    var strength: Double

    var isActive: Bool { strength > 0 }

    /// A consistent low-right offset plus jitter, applied to a whole tap.
    func tapDisplacement() -> CGVector {
        CGVector(dx: strength * (7 + 4.5 * gaussian()), dy: strength * (2.5 + 4.5 * gaussian()))
    }

    /// Smaller wobble for sliding.
    func slideJitter() -> CGVector {
        let phase = ProcessInfo.processInfo.systemUptime * 8
        return CGVector(dx: strength * (3 * sin(phase) + 1.5 * gaussian()),
                        dy: strength * (3 * cos(phase * 1.3) + 1.5 * gaussian()))
    }

    var doubleTapExtraContactChance: Double { 0.3 * strength }

    func holdExtraMovement() -> Double { strength * (3 + 2.5 * abs(gaussian())) }

    var keyboardSimulation: TouchSimulation? {
        guard isActive else { return nil }
        return TouchSimulation(displacement: tapDisplacement, extraContactChance: 0.16 * strength)
    }

    private func gaussian() -> Double {
        let u = Double.random(in: Double.ulpOfOne..<1)
        return sqrt(-2 * log(u)) * cos(2 * .pi * Double.random(in: 0..<1))
    }
}
