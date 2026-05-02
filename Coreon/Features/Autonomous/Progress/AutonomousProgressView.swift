import SwiftUI

struct AutonomousProgressView: View {
    @EnvironmentObject var autonomousVM: AutonomousViewModel

    var avgEnergy: Double {
        let v = autonomousVM.checkins.compactMap { $0.energyLevel }
        return v.isEmpty ? 0 : Double(v.reduce(0, +)) / Double(v.count)
    }
    var avgSleep: Double {
        let v = autonomousVM.checkins.compactMap { $0.sleepQuality }
        return v.isEmpty ? 0 : Double(v.reduce(0, +)) / Double(v.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // XP Progress
                    CoreonCard {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Nível \(autonomousVM.xp / 100 + 1)")
                                        .font(CoreonFonts.bold(20))
                                        .foregroundColor(CoreonColors.textPrimary)
                                    Text("\(autonomousVM.xp) XP acumulados")
                                        .font(CoreonFonts.regular(13))
                                        .foregroundColor(CoreonColors.textMuted)
                                }
                                Spacer()
                                Image(systemName: "star.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(CoreonColors.amber)
                            }

                            let progress = Double(autonomousVM.xp % 100) / 100.0
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6).fill(CoreonColors.border).frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(LinearGradient.autonomousGradient)
                                        .frame(width: geo.size.width * progress, height: 10)
                                }
                            }
                            .frame(height: 10)

                            Text("\(100 - (autonomousVM.xp % 100)) XP para o próximo nível")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.md)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(label: "Treinos", value: "\(autonomousVM.completedWorkouts)", icon: "dumbbell.fill", color: CoreonColors.violet)
                        StatCard(label: "Streak", value: "\(autonomousVM.streak) dias", icon: "flame.fill", color: CoreonColors.amber)
                        StatCard(label: "Energia média", value: String(format: "%.1f/10", avgEnergy), icon: "bolt.fill", color: CoreonColors.primary)
                        StatCard(label: "Sono médio", value: String(format: "%.1f/10", avgSleep), icon: "moon.fill", color: CoreonColors.cyan)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    // Check-in log
                    if !autonomousVM.checkins.isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Histórico de check-ins")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                            ForEach(autonomousVM.checkins.prefix(10)) { c in
                                CheckinCard(checkin: c)
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Progresso")
        }
    }
}
