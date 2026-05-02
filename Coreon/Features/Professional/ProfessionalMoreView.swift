import SwiftUI

struct ProfessionalMoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var proVM: ProfessionalViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Profile card
                    CoreonCard {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(CoreonColors.primary.opacity(0.15))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Text(String(authManager.currentUser?.fullName?.prefix(1) ?? "P"))
                                        .font(CoreonFonts.bold(24))
                                        .foregroundColor(CoreonColors.primary)
                                )
                            VStack(alignment: .leading, spacing: 3) {
                                Text(authManager.currentUser?.fullName ?? "Profissional")
                                    .font(CoreonFonts.bold(18))
                                    .foregroundColor(CoreonColors.textPrimary)
                                Text(authManager.currentUser?.email ?? "")
                                    .font(CoreonFonts.regular(13))
                                    .foregroundColor(CoreonColors.textMuted)
                                CoreonBadge(text: "\(proVM.clients.count) clientes", color: CoreonColors.primary)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.lg)

                    // Menu
                    VStack(spacing: 2) {
                        MenuSection(title: "Gestão") {
                            NavigationLink(destination: ProfessionalClassesView()) {
                                MenuRow(icon: "person.3.fill", title: "Aulas em grupo", color: CoreonColors.cyan)
                            }
                            NavigationLink(destination: ProfessionalFinancialView()) {
                                MenuRow(icon: "creditcard.fill", title: "Financeiro", color: CoreonColors.amber)
                            }
                            NavigationLink(destination: ProfessionalMessagesListView()) {
                                MenuRow(icon: "message.fill", title: "Mensagens", color: CoreonColors.primary)
                            }
                        }

                        MenuSection(title: "Conta") {
                            ProfileMenuItem(icon: "person.circle.fill", title: "Editar perfil", color: CoreonColors.textSecondary) {}
                            ProfileMenuItem(icon: "arrow.triangle.2.circlepath", title: "Trocar modo") {
                                appState.clearMode()
                            }
                            ProfileMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Sair da conta", color: CoreonColors.danger) {
                                authManager.logout()
                            }
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                }
                .padding(.bottom, 40)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Mais")
        }
    }
}

private struct MenuSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(CoreonFonts.semibold(12))
                .foregroundColor(CoreonColors.textMuted)
                .padding(.horizontal, 4)
                .padding(.top, 12)
            content
        }
    }
}

private struct MenuRow: View {
    let icon: String
    let title: String
    var color: Color = CoreonColors.primary

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            Text(title)
                .font(CoreonFonts.medium(15))
                .foregroundColor(CoreonColors.textPrimary)
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
}
