import CoreGraphics
import Foundation

/// Where one person's touches land around the key they mean: a two-dimensional
/// Gaussian with a mean offset and a spread on each axis.
///
/// It starts from the setup exercises and keeps learning in the keyboard as
/// the person types: every word they keep says which key each touch was for.
/// Only these few numbers are stored, never what was typed.
struct TouchModel: Codable, Equatable {
    /// Average offset of a touch from the centre of the key it was meant for, in points.
    var meanX: Double = 0
    var meanY: Double = 0
    /// Standard deviation of touches around that average, in points.
    var sigmaX: Double = 8
    var sigmaY: Double = 8
    /// How many touches it has learned from.
    var samples: Int = 0

    static let minimumSigma: Double = 4
    static let maximumSigma: Double = 32
    /// After this many samples, new touches keep a steady weight, so the model
    /// follows slow change (a better or worse week) instead of freezing.
    static let memory = 300

    init(meanX: Double = 0, meanY: Double = 0, sigmaX: Double = 8, sigmaY: Double = 8, samples: Int = 0) {
        self.meanX = meanX
        self.meanY = meanY
        self.sigmaX = Self.clamp(sigmaX)
        self.sigmaY = Self.clamp(sigmaY)
        self.samples = samples
    }

    /// log P(touch at offset | meant this key), dropping the constant.
    func logLikelihood(dx: Double, dy: Double) -> Double {
        let zx = (dx - meanX) / sigmaX
        let zy = (dy - meanY) / sigmaY
        return -0.5 * (zx * zx + zy * zy) - log(sigmaX * sigmaY)
    }

    /// Learns from one touch whose intended key is now known.
    mutating func learn(dx: Double, dy: Double) {
        // Ignore wild outliers (a touch on the far side of the keyboard was not "meant" for this key).
        guard abs(dx - meanX) < 4 * sigmaX + 10, abs(dy - meanY) < 4 * sigmaY + 10 else { return }
        samples += 1
        let w = 1 / Double(min(samples, Self.memory))
        let ex = dx - meanX, ey = dy - meanY
        meanX += w * ex
        meanY += w * ey
        sigmaX = Self.clamp(sqrt((1 - w) * sigmaX * sigmaX + w * ex * ex))
        sigmaY = Self.clamp(sqrt((1 - w) * sigmaY * sigmaY + w * ey * ey))
    }

    static func clamp(_ sigma: Double) -> Double {
        min(maximumSigma, max(minimumSigma, sigma.isFinite ? sigma : 8))
    }
}
