import SwiftUI

struct WelcomeView: View {
    @State private var navigateTo: AuthDestination? = nil

    enum AuthDestination { case login, register }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#052e16"), Color(hex: "#14532d")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo
                    VStack(spacing: CoreonSpacing.xl) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Text("C")
                                .font(.system(size: 52, weight: .black))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 8) {
                            Text("Bem-vindo ao\nCoreon")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            Text("Treinamento inteligente para todos")
                                .font(CoreonFonts.regular(16))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }

                        // Features
                        VStack(spacing: 12) {
                            FeatureRow(icon: "bolt.fill", text: "Treinos personalizados com IA")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Acompanhamento de evolução")
                            FeatureRow(icon: "person.2.fill", text: "Trainer + Aluno integrados")
                        }
                        .padding(.top, 8)
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: 12) {
                        NavigationLink(destination: LoginView()) {
                            Text("Entrar")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(Color(hex: "#052e16"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.white)
                                .cornerRadius(CoreonRadius.lg)
                        }

                        NavigationLink(destination: RegisterView()) {
                            Text("Criar conta")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(CoreonRadius.lg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CoreonRadius.lg)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(CoreonColors.primary)
                .frame(width: 28, height: 28)
                .background(CoreonColors.primary.opacity(0.15))
                .cornerRadius(8)

            Text(text)
                .font(CoreonFonts.medium(14))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
        }
    }
}
