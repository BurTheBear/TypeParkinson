import CoreGraphics

enum KeySize: String, Codable, CaseIterable, Identifiable {
    case standard = "Standard"
    case large = "Large"
    case extraLarge = "Extra large"

    var id: String { rawValue }

    var keyHeight: CGFloat {
        switch self {
        case .standard: 42
        case .large: 52
        case .extraLarge: 60
        }
    }

    var gap: CGFloat {
        switch self {
        case .standard: 4
        case .large: 6
        case .extraLarge: 8
        }
    }

    /// Four rows of keys; independent of width.
    var keyboardHeight: CGFloat { 4 * keyHeight + 3 * gap }
}

enum KeyAction: Hashable {
    case character(String)
    case space
    case backspace
    case shift
    case nextKeyboard
    case returnKey
}

struct Key: Identifiable, Hashable {
    let id: String
    let label: String
    let action: KeyAction
    let frame: CGRect
    let row: Int

    var isLetter: Bool {
        if case .character(let c) = action { return c.first?.isLetter == true }
        return false
    }
}

/// QWERTY layout matching the mockup. `systemKeys` adds the shift, globe and
/// return keys a system keyboard needs; the in-app typing tasks leave them out.
struct KeyboardLayout {
    let size: KeySize
    let width: CGFloat
    let keys: [Key]

    var height: CGFloat { size.keyboardHeight }

    init(size: KeySize, width: CGFloat, systemKeys: Bool) {
        self.size = size
        self.width = width
        let h = size.keyHeight, gap = size.gap
        let keyWidth = (width - 9 * gap) / 10
        let unit = keyWidth + gap
        let rowY = { (row: Int) in CGFloat(row) * (h + gap) }

        var keys: [Key] = []
        func add(_ id: String, _ label: String, _ action: KeyAction, x: CGFloat, w: CGFloat, row: Int) {
            keys.append(Key(id: id, label: label, action: action,
                            frame: CGRect(x: x, y: rowY(row), width: w, height: h), row: row))
        }
        func letters(_ row: String, x0: CGFloat, row index: Int) {
            for (i, c) in row.enumerated() {
                add(String(c), String(c), .character(String(c)), x: x0 + CGFloat(i) * unit, w: keyWidth, row: index)
            }
        }

        letters("qwertyuiop", x0: 0, row: 0)
        letters("asdfghjkl", x0: unit / 2, row: 1)
        if systemKeys {
            add("shift", "⇧", .shift, x: 0, w: keyWidth, row: 2)
        }
        letters("zxcvbnm", x0: unit, row: 2)
        add("bs", "⌫", .backspace, x: 8 * unit, w: width - 8 * unit, row: 2)

        if systemKeys {
            add("globe", "🌐", .nextKeyboard, x: 0, w: 1.5 * unit - gap, row: 3)
            add(",", ",", .character(","), x: 1.5 * unit, w: unit - gap, row: 3)
            add(" ", "space", .space, x: 2.5 * unit, w: 5 * unit - gap, row: 3)
            add(".", ".", .character("."), x: 7.5 * unit, w: unit - gap, row: 3)
            add("return", "return", .returnKey, x: 8.5 * unit, w: width - 8.5 * unit, row: 3)
        } else {
            add(",", ",", .character(","), x: 0, w: 2 * unit - gap, row: 3)
            add(" ", "space", .space, x: 2 * unit, w: 6 * unit - gap, row: 3)
            add(".", ".", .character("."), x: 8 * unit, w: width - 8 * unit, row: 3)
        }
        self.keys = keys
    }

    /// The key a touch at `point` selects: its row by height, then the
    /// horizontally nearest key in that row, so gaps never swallow a touch.
    func key(at point: CGPoint) -> Key? {
        let gap = size.gap
        guard point.y >= -gap - 6, point.y <= height + gap + 6,
              point.x >= -10, point.x <= width + 10 else { return nil }
        let row = max(0, min(3, Int(((point.y + gap / 2) / (size.keyHeight + gap)).rounded(.down))))
        return keys
            .filter { $0.row == row }
            .min { distance(point.x, $0.frame) < distance(point.x, $1.frame) }
    }

    private func distance(_ x: CGFloat, _ frame: CGRect) -> CGFloat {
        max(frame.minX - x, 0, x - frame.maxX)
    }
}
