import SwiftUI

struct LoadingView: View {
    var message: String = "Carregando..."
    var color: Color = CoreonColors.primary

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: color))
                .scaleEffect(1.3)
            Text(message)
                .font(CoreonFonts.regular(14))
                .foregroundColor(CoreonColors.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AsyncContentView<Content: View>: View {
    let isLoading: Bool
    let error: String?
    let content: Content

    init(isLoading: Bool, error: String? = nil, @ViewBuilder content: () -> Content) {
        self.isLoading = isLoading
        self.error = error
        self.content = content()
    }

    var body: some View {
        if isLoading {
            LoadingView()
        } else if let error = error {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36))
                    .foregroundColor(CoreonColors.danger)
                Text(error)
                    .font(CoreonFonts.regular(14))
                    .foregroundColor(CoreonColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else {
            content
        }
    }
}
