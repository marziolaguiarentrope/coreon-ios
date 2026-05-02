import SwiftUI

struct CoreonButton: View {
    enum Style { case primary, secondary, outline, ghost, danger }

    let title: String
    let style: Style
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, style: Style = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(CoreonFonts.semibold(16))
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .cornerRadius(CoreonRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CoreonRadius.lg)
                    .stroke(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return CoreonColors.primary
        case .outline: return CoreonColors.primary
        case .ghost: return CoreonColors.textSecondary
        case .danger: return .white
        }
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .primary: LinearGradient.primaryGradient
        case .secondary: CoreonColors.primary.opacity(0.1)
        case .outline: Color.clear
        case .ghost: Color.clear
        case .danger: CoreonColors.danger
        }
    }

    private var borderColor: Color {
        style == .outline ? CoreonColors.primary : .clear
    }
}

// MARK: - Icon Button
struct CoreonIconButton: View {
    let icon: String
    let action: () -> Void
    var color: Color = CoreonColors.textSecondary
    var size: CGFloat = 20

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
        }
    }
}
