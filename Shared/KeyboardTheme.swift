import SwiftUI

/// How the keyboard looks. The layout never changes with the theme, only colour.
enum KeyboardTheme: String, Codable, CaseIterable, Identifiable {
    case classic = "Classic"
    /// White labels on near-black keys, a yellow press. The same in light and dark mode.
    case highContrast = "High contrast"
    /// Soft blue keys, for people who find bright white keys glaring.
    case calm = "Calm"

    var id: String { rawValue }

    struct Palette {
        var background: Color
        /// Keys that type something.
        var inputKey: Color
        /// Shift, delete, return, space and the mode keys.
        var functionKey: Color
        var pressed: Color
        var label: Color
        var pressedLabel: Color
        var keyShadow: Color
    }

    var palette: Palette {
        switch self {
        case .classic:
            Palette(background: Theme.neutral200, inputKey: Theme.bg, functionKey: Theme.neutral300,
                    pressed: Theme.accent300, label: Theme.text, pressedLabel: Theme.text,
                    keyShadow: .black.opacity(0.18))
        case .highContrast:
            Palette(background: Color(rgb: 0x000000), inputKey: Color(rgb: 0x2C2C2F),
                    functionKey: Color(rgb: 0x4A4A4F), pressed: Color(rgb: 0xFFD60A),
                    label: Color(rgb: 0xFFFFFF), pressedLabel: Color(rgb: 0x000000),
                    keyShadow: .clear)
        case .calm:
            Palette(background: Color(light: 0xDDE6F3, dark: 0x0F1828),
                    inputKey: Color(light: 0xF8FAFE, dark: 0x1D2A3E),
                    functionKey: Color(light: 0xC3D2E8, dark: 0x2D3D56),
                    pressed: Color(light: 0x9CC3FF, dark: 0x2F5FA8),
                    label: Color(light: 0x14213A, dark: 0xE6EDF8),
                    pressedLabel: Color(light: 0x14213A, dark: 0xFFFFFF),
                    keyShadow: .black.opacity(0.12))
        }
    }

    var summary: String {
        switch self {
        case .classic: "Light keys on grey, like the mockup."
        case .highContrast: "White on black with a yellow press. Easiest to see."
        case .calm: "Soft blue keys with less glare."
        }
    }
}
