import SwiftUI

struct ChooseModeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @State private var selectedMode: AppMode? = nil
    @State private var showConfirm = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0f172a"), Color(hex: "#1e293b")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: CoreonSpacing.xxl) {
                    // Header
                    VStack(spacing: 8) {
                        if let name = authManager.currentUser?.fullName {
                            Text("Olá, \(name.components(separatedBy: " ").first ?? name)!")
                                .font(CoreonFonts.bold(26))
                                .foregroundColor(.white)
                        } else {
                            Text("Como você vai usar\no Coreon?")
                                .font(CoreonFonts.bold(26))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        Text("Escolha seu perfil de acesso")
                            .font(CoreonFonts.regular(15))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, CoreonSpacing.xxxl)

                    // Mode cards
                    VStack(spacing: CoreonSpacing.md) {
                        ModeCard(
                            mode: .professional,
                            icon: "person.crop.circle.badge.checkmark",
                            title: "Profissional",
                            subtitle: "Treinador ou nutricionista",
                            description: "Gerencie clientes, crie programas de treino, anamneses e acompanhe resultados.",
                            color: CoreonColors.primary,
                            gradient: [Color(hex: "#052e16"), Color(hex: "#14532d")],
                            selected: selectedMode == .professional
                        ) { selectedMode = .professional }

                        ModeCard(
                            mode: .student,
                            icon: "figure.run",
                            title: "Aluno",
                            subtitle: "Acompanhe seus treinos",
                            description: "Veja seus treinos, progresso, mensagens do seu profissional e agendamentos.",
                            color: CoreonColors.cyan,
                            gradient: [Color(hex: "#0c4a6e"), Color(hex: "#0369a1")],
                            selected: selectedMode == .student
                        ) { selectedMode = .student }

                        ModeCard(
                            mode: .autonomous,
                            icon: "sparkles",
                            title: "Autônomo IA",
                            subtitle: "Treinamento com inteligência artificial",
                            description: "Deixe a IA criar seu plano personalizado, monitore progresso e evolua sozinho.",
                            color: CoreonColors.violet,
                            gradient: [Color(hex: "#2e1065"), Color(hex: "#4c1d95")],
                            selected: selectedMode == .autonomous
                        ) { selectedMode = .autonomous }
                    }

                    if let mode = selectedMode {
                        CoreonButton("Entrar como \(modeName(mode))") {
                            appState.selectedMode = mode
                        }
                        .padding(.top, 8)
                    }

                    Button("Sair da conta") {
                        authManager.logout()
                    }
                    .font(CoreonFonts.regular(13))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, CoreonSpacing.xl)
            }
        }
    }

    private func modeName(_ mode: AppMode) -> String {
        switch mode {
        case .student: return "Aluno"
        case .professional: return "Profissional"
        case .autonomous: return "Autônomo"
        }
    }
}

private struct ModeCard: View {
    let mode: AppMode
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    let gradient: [Color]
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CoreonSpacing.lg) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: CoreonRadius.md)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(CoreonFonts.bold(17))
                                .foregroundColor(.white)
                            Text(subtitle)
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(color)
                        }
                    }
                    Text(description)
                        .font(CoreonFonts.regular(12))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }
            .padding(CoreonSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CoreonRadius.lg)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: CoreonRadius.lg)
                            .stroke(selected ? color : Color.white.opacity(0.1), lineWidth: selected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
