import SwiftUI

struct AutonomousProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var autonomousVM: AutonomousViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Hero card
                    ZStack {
                        LinearGradient.autonomousGradient
                            .cornerRadius(CoreonRadius.xl)

                        VStack(spacing: CoreonSpacing.md) {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(String(authManager.currentUser?.fullName?.prefix(1) ?? "A"))
                                        .font(CoreonFonts.bold(36))
                                        .foregroundColor(.white)
                                )

                            VStack(spacing: 4) {
                                Text(authManager.currentUser?.fullName ?? "Atleta")
                                    .font(CoreonFonts.bold(20))
                                    .foregroundColor(.white)
                                Text(authManager.currentUser?.email ?? "")
                                    .font(CoreonFonts.regular(13))
                                    .foregroundColor(.white.opacity(0.7))
                            }

                            HStack(spacing: 24) {
                                VStack(spacing: 2) {
                                    Text("\(autonomousVM.xp)").font(CoreonFonts.bold(18)).foregroundColor(.white)
                                    Text("XP").font(.system(size: 11)).foregroundColor(.white.opacity(0.7))
                                }
                                VStack(spacing: 2) {
                                    Text("\(autonomousVM.streak)").font(CoreonFonts.bold(18)).foregroundColor(.white)
                                    Text("Streak").font(.system(size: 11)).foregroundColor(.white.opacity(0.7))
                                }
                                VStack(spacing: 2) {
                                    Text("\(autonomousVM.completedWorkouts)").font(CoreonFonts.bold(18)).foregroundColor(.white)
                                    Text("Treinos").font(.system(size: 11)).foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding(CoreonSpacing.xl)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.lg)

                    // Profile info
                    if let profile = autonomousVM.profile {
                        CoreonCard {
                            VStack(spacing: 12) {
                                ProfileInfoRow(label: "Objetivo", value: profile.goal ?? "-")
                                Divider()
                                ProfileInfoRow(label: "Nível", value: profile.fitnessLevel ?? "-")
                                Divider()
                                ProfileInfoRow(label: "Dias/semana", value: "\(profile.daysPerWeek ?? 0)")
                                if let r = profile.restrictions, !r.isEmpty {
                                    Divider()
                                    ProfileInfoRow(label: "Restrições", value: r)
                                }
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }

                    // Actions
                    VStack(spacing: 8) {
                        CoreonButton("Refazer onboarding / Atualizar plano", style: .outline) {
                            autonomousVM.needsOnboarding = true
                        }
                        CoreonButton("Trocar modo", style: .ghost) {
                            appState.clearMode()
                        }
                        CoreonButton("Sair da conta", style: .danger) {
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

private struct ProfileInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(CoreonFonts.regular(14))
                .foregroundColor(CoreonColors.textMuted)
            Spacer()
            Text(value)
                .font(CoreonFonts.semibold(14))
                .foregroundColor(CoreonColors.textPrimary)
        }
    }
}
