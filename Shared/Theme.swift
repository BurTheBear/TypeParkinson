import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// The TypeParkinson look ("Aura"): a cool light ground with white cards, a
/// living colour field built from the person's own touches as the signature,
/// one electric blue for the keyboard and the check, and a colour per activity.
/// SF Pro Rounded for display and numbers, SF Pro for reading.
enum Theme {
    static let bg = Color(light: 0xF3F4F8, dark: 0x07090F)
    /// Cards on the page.
    static let card = Color(light: 0xFFFFFF, dark: 0x141821)
    /// Recessed areas: plots, exercise surfaces, inputs, rows inside cards.
    static let surface = Color(light: 0xEEF0F5, dark: 0x1D2230)
    static let text = Color(light: 0x0E1424, dark: 0xF2F4FA)
    static let secondaryText = Color(light: 0x5B6377, dark: 0x9AA3B8)
    static let divider = Color(light: 0xE3E6EE, dark: 0x262C3A)

    static let neutral200 = Color(light: 0xE4E7EF, dark: 0x1D2230)
    static let neutral300 = Color(light: 0xD3D7E2, dark: 0x2A3142)
    static let neutral400 = Color(light: 0xAEB4C4, dark: 0x4A5368)
    static let neutral600 = Color(light: 0x7C8396, dark: 0x8790A6)

    static let accent = Color(light: 0x2F5BFF, dark: 0x6E8EFF)
    static let accent100 = Color(light: 0xE8EDFF, dark: 0x16224F)
    static let accent300 = Color(light: 0xB9C8FF, dark: 0x27408F)
    static let accent400 = Color(light: 0x8AA3FF, dark: 0x3A59C9)
    static let accent600 = Color(light: 0x2347D6, dark: 0x8AA3FF)
    static let accent700 = Color(light: 0x1A36A8, dark: 0xB9C8FF)
    /// Something got worse or needs attention. Always paired with an icon or words.
    static let warning = Color(light: 0xD92D63, dark: 0xFF7097)
    /// Something improved. Always paired with an arrow and words.
    static let positive = Color(light: 0x0B9A74, dark: 0x3FE0B5)

    /// One colour per activity, so each is recognisable at a glance everywhere.
    static let checkColor = accent
    static let spiralColor = Color(light: 0x00A0A0, dark: 0x2BD4C4)
    static let tappingColor = Color(light: 0xFF5F33, dark: 0xFF8A65)
    static let typingColor = Color(light: 0xDB2F78, dark: 0xFF6FA5)
    static let speakColor = Color(light: 0x0F9D63, dark: 0x3FE0A0)
    static let tremorColor = Color(light: 0x6E4DFF, dark: 0x9C86FF)
    static let voiceColor = Color(light: 0xE89400, dark: 0xFFC94D)
    static let medsColor = Color(light: 0x168BD0, dark: 0x5CC4FF)

    /// The deep ink behind the Aura.
    static let ink = Color(rgb: 0x0A0F1F)

    static let cornerRadius: CGFloat = 12
    static let controlRadius: CGFloat = 16
    static let cardRadius: CGFloat = 26
    static let heroRadius: CGFloat = 34
    static let keyRadius: CGFloat = 8

    /// 4-point spacing scale.
    enum Space {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s5: CGFloat = 20
        static let s6: CGFloat = 24
        static let s8: CGFloat = 32
        static let s10: CGFloat = 40
    }

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .default, weight: weight)
    }

    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Numbers and big display figures.
    static func rounded(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

    static func rounded(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
        #elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return NSColor(rgb: isDark ? dark : light)
        })
        #endif
    }

    init(rgb: UInt32) {
        self.init(light: rgb, dark: rgb)
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(red: CGFloat((rgb >> 16) & 0xFF) / 255,
                  green: CGFloat((rgb >> 8) & 0xFF) / 255,
                  blue: CGFloat(rgb & 0xFF) / 255,
                  alpha: 1)
    }
}
#elseif canImport(AppKit)
private extension NSColor {
    convenience init(rgb: UInt32) {
        self.init(srgbRed: CGFloat((rgb >> 16) & 0xFF) / 255,
                  green: CGFloat((rgb >> 8) & 0xFF) / 255,
                  blue: CGFloat(rgb & 0xFF) / 255,
                  alpha: 1)
    }
}
#endif
