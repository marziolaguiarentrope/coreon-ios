import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#052e16"), Color(hex: "#14532d"), Color(hex: "#166534")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: CoreonSpacing.xl) {
                // Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Text("C")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                VStack(spacing: 8) {
                    Text("Coreon")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                        .opacity(opacity)

                    Text("Seu parceiro fitness inteligente")
                        .font(CoreonFonts.regular(16))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
