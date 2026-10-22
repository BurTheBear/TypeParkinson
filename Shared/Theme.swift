import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Colours and type from the TypeParkinson mockup ("broadsheet" design system).
enum Theme {
    static let bg = Color(light: 0xF3F2F2, dark: 0x1B1A1D)
    static let surface = Color(light: 0xEAE9E9, dark: 0x252428)
    static let text = Color(light: 0x201E1D, dark: 0xEFEDF0)
    static let divider = Color(light: 0xD7D3D3, dark: 0x3A393D)

    static let neutral200 = Color(light: 0xEAE7E7, dark: 0x2A292D)
    static let neutral300 = Color(light: 0xD7D3D3, dark: 0x3A393D)
    static let neutral400 = Color(light: 0xBAB6B6, dark: 0x4F4E52)
    static let neutral600 = Color(light: 0x7D7979, dark: 0x8A898E)
    static let secondaryText = Color(light: 0x605D5D, dark: 0xAAA9AD)

    static let accent = Color(light: 0x035EDE, dark: 0x59A0F9)
    static let accent100 = Color(light: 0xECF6FF, dark: 0x0C204F)
    static let accent300 = Color(light: 0xAFD4FF, dark: 0x063EA9)
    static let accent400 = Color(light: 0x7AB3FF, dark: 0x004FC8)
    static let accent600 = Color(light: 0x004FC8, dark: 0x7AB3FF)
    static let accent700 = Color(light: 0x063EA9, dark: 0xAFD4FF)
    static let warning = Color(light: 0xAE1A69, dark: 0xFFBDD7)

    static let cornerRadius: CGFloat = 4

    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .default, weight: weight)
    }

    static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
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
}

#if canImport(UIKit)
private extension UIColor {
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
