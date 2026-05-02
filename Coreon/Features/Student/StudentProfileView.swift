import SwiftUI

struct StudentProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var studentVM: StudentViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Avatar + name
                    VStack(spacing: CoreonSpacing.md) {
                        Circle()
                            .fill(CoreonColors.cyan.opacity(0.15))
                            .frame(width: 84, height: 84)
                            .overlay(
                                Text(String(authManager.currentUser?.fullName?.prefix(1) ?? "A"))
                                    .font(CoreonFonts.bold(36))
                                    .foregroundColor(CoreonColors.cyan)
                            )

                        VStack(spacing: 4) {
                            Text(authManager.currentUser?.fullName ?? "Atleta")
                                .font(CoreonFonts.bold(22))
                                .foregroundColor(CoreonColors.textPrimary)
                            Text(authManager.currentUser?.email ?? "")
                                .font(CoreonFonts.regular(14))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                    .padding(.top, CoreonSpacing.xxl)

                    // Stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(label: "Treinos", value: "\(studentVM.workouts.count)", color: CoreonColors.cyan)
                        StatCard(label: "Check-ins", value: "\(studentVM.checkins.count)", color: CoreonColors.primary)
                        StatCard(label: "Mensagens", value: "\(studentVM.messages.count)", color: CoreonColors.violet)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    // Menu items
                    VStack(spacing: 2) {
                        ProfileMenuItem(icon: "doc.text", title: "Anamneses", color: CoreonColors.violet) {}
                        ProfileMenuItem(icon: "calendar", title: "Agendamentos", color: CoreonColors.amber) {}
                        ProfileMenuItem(icon: "figure.walk", title: "Aulas em grupo", color: CoreonColors.cyan) {}
                        Divider().padding(.vertical, 8)
                        ProfileMenuItem(icon: "arrow.triangle.2.circlepath", title: "Trocar modo") {
                            appState.clearMode()
                        }
                        ProfileMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Sair da conta", color: CoreonColors.danger) {
                            authManager.logout()
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                }
                .padding(.bottom, 40)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Perfil")
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    var color: Color = CoreonColors.textSecondary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)

                Text(title)
                    .font(CoreonFonts.medium(15))
                    .foregroundColor(color == CoreonColors.danger ? CoreonColors.danger : CoreonColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(CoreonColors.textMuted)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, CoreonSpacing.md)
            .background(Color.white)
            .cornerRadius(CoreonRadius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
