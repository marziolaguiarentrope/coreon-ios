import SwiftUI

struct CoreonCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = CoreonSpacing.lg
    var shadow: Bool = true

    init(padding: CGFloat = CoreonSpacing.lg, shadow: Bool = true, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.white)
            .cornerRadius(CoreonRadius.lg)
            .shadow(
                color: shadow ? Color.black.opacity(0.05) : .clear,
                radius: 8, x: 0, y: 2
            )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let label: String
    let value: String
    var icon: String? = nil
    var color: Color = CoreonColors.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(CoreonFonts.bold(22))
                .foregroundColor(CoreonColors.textPrimary)
            Text(label)
                .font(CoreonFonts.regular(12))
                .foregroundColor(CoreonColors.textMuted)
        }
        .padding(CoreonSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.07))
        .cornerRadius(CoreonRadius.lg)
    }
}

// MARK: - Badge
struct CoreonBadge: View {
    let text: String
    var color: Color = CoreonColors.primary
    var size: CGFloat = 11

    var body: some View {
        Text(text)
            .font(CoreonFonts.semibold(size))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(CoreonRadius.pill)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "Criar"

    var body: some View {
        VStack(spacing: CoreonSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(CoreonColors.textMuted)
            VStack(spacing: 6) {
                Text(title)
                    .font(CoreonFonts.semibold(18))
                    .foregroundColor(CoreonColors.textPrimary)
                Text(message)
                    .font(CoreonFonts.regular(14))
                    .foregroundColor(CoreonColors.textMuted)
                    .multilineTextAlignment(.center)
            }
            if let action = action {
                CoreonButton(actionLabel, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(CoreonSpacing.xxl)
    }
}
