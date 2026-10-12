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
    var keyboardHeight: CGFloat { keyboardHeight(compact: false) }

    /// Landscape iPhones have little height to spare, so rows get shorter there.
    func keyHeight(compact: Bool) -> CGFloat {
        compact ? (keyHeight * 0.74).rounded() : keyHeight
    }

    func keyboardHeight(compact: Bool) -> CGFloat {
        4 * keyHeight(compact: compact) + 3 * gap
    }
}

enum KeyboardMode: Hashable {
    case letters
    case numbers
    case symbols
    /// Digits only, for number, decimal and phone fields.
    case numberPad
}

enum KeyAction: Hashable {
    case character(String)
    case space
    case backspace
    case shift
    case nextKeyboard
    case returnKey
    case mode(KeyboardMode)
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

    /// Keys that type something, drawn in the lighter colour.
    var isInput: Bool {
        if case .character = action { return true }
        return false
    }
}

/// QWERTY layout matching the mockup. With `systemKeys` it becomes a complete
/// system keyboard: shift, numbers and symbols, the globe key and return.
/// The in-app typing tasks leave those out.
struct KeyboardLayout {
    struct Options: Equatable {
        var systemKeys = false
        var mode: KeyboardMode = .letters
        /// iOS shows its own globe key below the keyboard on most current devices.
        var showsGlobe = true
        var returnLabel = "return"
        /// The key left of space: "," normally, "@" for email, "/" for web addresses.
        var punctuation = ","
        /// Bottom-left key of the number pad: "." for decimals, "+" for phone numbers.
        var numberPadExtra: String?
        var compact = false
    }

    let size: KeySize
    let width: CGFloat
    let height: CGFloat
    let keys: [Key]

    init(size: KeySize, width: CGFloat, options: Options = Options()) {
        self.size = size
        self.width = width
        let compact = options.compact
        let h = size.keyHeight(compact: compact), gap = size.gap
        self.height = size.keyboardHeight(compact: compact)

        var keys: [Key] = []
        func add(_ id: String, _ label: String, _ action: KeyAction, x: CGFloat, w: CGFloat, row: Int) {
            keys.append(Key(id: id, label: label, action: action,
                            frame: CGRect(x: x, y: CGFloat(row) * (h + gap), width: w, height: h), row: row))
        }

        let mode = options.systemKeys ? options.mode : .letters
        if mode == .numberPad {
            Self.numberPad(width: width, gap: gap, options: options, add: add)
            self.keys = keys
            return
        }

        let keyWidth = (width - 9 * gap) / 10
        let unit = keyWidth + gap
        func characters(_ row: String, prefix: String, x0: CGFloat, w: CGFloat = keyWidth, row index: Int) {
            for (i, c) in row.enumerated() {
                add(prefix + String(c), String(c), .character(String(c)), x: x0 + CGFloat(i) * (w + gap), w: w, row: index)
            }
        }

        switch mode {
        case .letters, .numberPad:
            characters("qwertyuiop", prefix: "", x0: 0, row: 0)
            characters("asdfghjkl", prefix: "", x0: unit / 2, row: 1)
            if options.systemKeys {
                add("shift", "shift", .shift, x: 0, w: keyWidth, row: 2)
            }
            characters("zxcvbnm", prefix: "", x0: unit, row: 2)
        case .numbers:
            characters("1234567890", prefix: "n", x0: 0, row: 0)
            characters("-/:;()$&@\"", prefix: "n", x0: 0, row: 1)
            add("toSymbols", "#+=", .mode(.symbols), x: 0, w: keyWidth, row: 2)
            characters(".,?!'", prefix: "n2", x0: unit, w: (7 * unit - 5 * gap) / 5, row: 2)
        case .symbols:
            characters("[]{}#%^*+=", prefix: "s", x0: 0, row: 0)
            characters("_\\|~<>€£¥•", prefix: "s", x0: 0, row: 1)
            add("toNumbers", "123", .mode(.numbers), x: 0, w: keyWidth, row: 2)
            characters(".,?!'", prefix: "s2", x0: unit, w: (7 * unit - 5 * gap) / 5, row: 2)
        }
        add("bs", "delete", .backspace, x: 8 * unit, w: width - 8 * unit, row: 2)

        guard options.systemKeys else {
            add(",", ",", .character(","), x: 0, w: 2 * unit - gap, row: 3)
            add(" ", "space", .space, x: 2 * unit, w: 6 * unit - gap, row: 3)
            add(".", ".", .character("."), x: 8 * unit, w: width - 8 * unit, row: 3)
            self.keys = keys
            return
        }

        // Bottom row, left to right; space takes whatever width is left.
        let modeKey: (String, KeyAction) = mode == .letters ? ("123", .mode(.numbers)) : ("ABC", .mode(.letters))
        var left: [(id: String, label: String, action: KeyAction, units: CGFloat)] = [
            ("mode", modeKey.0, modeKey.1, 1.25),
        ]
        if options.showsGlobe {
            left.append(("globe", "next keyboard", .nextKeyboard, 1.25))
        }
        if mode == .letters {
            left.append(("punct", options.punctuation, .character(options.punctuation), 1))
        }
        let right: [(id: String, label: String, action: KeyAction, units: CGFloat)] = [
            ("period", ".", .character("."), 1),
            ("return", options.returnLabel, .returnKey, 2),
        ]
        var x: CGFloat = 0
        for item in left {
            add(item.id, item.label, item.action, x: x, w: item.units * unit - gap, row: 3)
            x += item.units * unit
        }
        let rightWidth = right.reduce(0) { $0 + $1.units } * unit
        add(" ", "space", .space, x: x, w: width - rightWidth - x - gap, row: 3)
        x = width - rightWidth
        for item in right {
            let w = item.id == "return" ? width - x : item.units * unit - gap
            add(item.id, item.label, item.action, x: x, w: w, row: 3)
            x += item.units * unit
        }
        self.keys = keys
    }

    /// Phone-style digits with delete, return and the globe key in a fourth column.
    private static func numberPad(width: CGFloat, gap: CGFloat, options: Options,
                                  add: (String, String, KeyAction, CGFloat, CGFloat, Int) -> Void) {
        let w = (width - 3 * gap) / 4
        let column = { (i: Int) in CGFloat(i) * (w + gap) }
        for (index, digit) in "123456789".enumerated() {
            add("d\(digit)", String(digit), .character(String(digit)), column(index % 3), w, index / 3)
        }
        if let extra = options.numberPadExtra {
            add("dExtra", extra, .character(extra), column(0), w, 3)
        }
        add("d0", "0", .character("0"), column(1), w, 3)
        add("bs", "delete", .backspace, column(3), width - column(3), 0)
        add("return", options.returnLabel, .returnKey, column(3), width - column(3), 1)
        if options.showsGlobe {
            add("globe", "next keyboard", .nextKeyboard, column(3), width - column(3), 2)
        }
    }

    /// The key a touch at `point` selects: its row by height, then the
    /// horizontally nearest key in that row, so gaps never swallow a touch.
    func key(at point: CGPoint) -> Key? {
        let gap = size.gap
        guard point.y >= -gap - 6, point.y <= height + gap + 6,
              point.x >= -10, point.x <= width + 10 else { return nil }
        let rowHeight = (height + gap) / 4
        let row = max(0, min(3, Int(((point.y + gap / 2) / rowHeight).rounded(.down))))
        return keys
            .filter { $0.row == row }
            .min { distance(point.x, $0.frame) < distance(point.x, $1.frame) }
    }

    private func distance(_ x: CGFloat, _ frame: CGRect) -> CGFloat {
        max(frame.minX - x, 0, x - frame.maxX)
    }
}
