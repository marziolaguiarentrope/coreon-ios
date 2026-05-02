import SwiftUI

// MARK: - Coreon Design System

struct CoreonColors {
    // Primary
    static let primary = Color(hex: "#22c55e")
    static let primaryLight = Color(hex: "#4ade80")
    static let primaryDark = Color(hex: "#16a34a")

    // Accents
    static let cyan = Color(hex: "#06b6d4")
    static let violet = Color(hex: "#8b5cf6")
    static let amber = Color(hex: "#f59e0b")
    static let rose = Color(hex: "#f43f5e")

    // Surfaces
    static let background = Color(hex: "#f8fafc")
    static let backgroundDark = Color(hex: "#0f172a")
    static let card = Color.white
    static let cardDark = Color(hex: "#1e293b")

    // Text
    static let textPrimary = Color(hex: "#0f172a")
    static let textSecondary = Color(hex: "#475569")
    static let textMuted = Color(hex: "#94a3b8")
    static let textInverted = Color.white

    // Borders
    static let border = Color(hex: "#e2e8f0")
    static let borderStrong = Color(hex: "#cbd5e1")

    // Status
    static let success = Color(hex: "#22c55e")
    static let warning = Color(hex: "#f59e0b")
    static let danger = Color(hex: "#ef4444")
    static let info = Color(hex: "#3b82f6")

    // Mode-specific
    static let professionalAccent = Color(hex: "#22c55e")
    static let autonomousAccent = Color(hex: "#8b5cf6")
    static let studentAccent = Color(hex: "#06b6d4")
}

struct CoreonSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

struct CoreonRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let pill: CGFloat = 999
}

struct CoreonFonts {
    static func light(_ size: CGFloat) -> Font { .system(size: size, weight: .light) }
    static func regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
    static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium) }
    static func semibold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    static func bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold) }
    static func heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy) }
}

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient helpers
extension LinearGradient {
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [CoreonColors.primary, CoreonColors.primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var autonomousGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#7c3aed"), Color(hex: "#4f46e5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var darkGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#0f172a"), Color(hex: "#1e293b")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
