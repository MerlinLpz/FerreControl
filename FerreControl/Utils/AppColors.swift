// Tokens de diseño de FerreControl — paleta terracota peruana
import SwiftUI

// MARK: - Inicializador hex para Color

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Paleta de color

extension Color {
    static let fcBrand        = Color(hex: "B23A1F")  // Terracota peruano
    static let fcBrandPress   = Color(hex: "962F18")
    static let fcBrand2       = Color(hex: "D9542B")
    static let fcBrandSoft    = Color(hex: "FBEAE3")
    static let fcBrandSoftFg  = Color(hex: "7A2412")
    static let fcBgApp        = Color(hex: "F4F1ED")  // Papel kraft cálido
    static let fcBgCard       = Color(hex: "FFFFFF")
    static let fcBgInput      = Color(hex: "F1EDE7")
    static let fcFg           = Color(hex: "1A1614")  // Carbón cálido
    static let fcFg2          = Color(hex: "5C544B")
    static let fcFg3          = Color(hex: "9A9189")
    static let fcSeparator    = Color(hex: "EAE3D9")
    static let fcSuccess      = Color(hex: "1F7A3D")
    static let fcSuccessBg    = Color(hex: "E3F0E5")
    static let fcWarning      = Color(hex: "E08900")
    static let fcWarningBg    = Color(hex: "FDEFD3")
    static let fcDanger       = Color(hex: "C7321F")
    static let fcDangerBg     = Color(hex: "FBE3DE")
}

// MARK: - Radio de esquinas

enum FCRadius {
    static let sm: CGFloat    = 10
    static let btn: CGFloat   = 14
    static let card: CGFloat  = 16
    static let sheet: CGFloat = 20
}

// MARK: - Espaciado

enum FCSpace {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 24
    static let s7: CGFloat = 32
}
