import SwiftUI

struct StudentProgressView: View {
    @EnvironmentObject var studentVM: StudentViewModel

    var completedWorkouts: [Workout] {
        studentVM.workouts.filter { $0.status == "completed" }
    }

    var totalWorkouts: Int { studentVM.workouts.count }

    var adherenceRate: Double {
        guard totalWorkouts > 0 else { return 0 }
        return Double(completedWorkouts.count) / Double(totalWorkouts) * 100
    }

    var avgEnergy: Double {
        let values = studentVM.checkins.compactMap { $0.energyLevel }
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Summary cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(label: "Treinos feitos", value: "\(completedWorkouts.count)", icon: "checkmark.circle.fill", color: CoreonColors.primary)
                        StatCard(label: "Adesão", value: String(format: "%.0f%%", adherenceRate), icon: "chart.bar.fill", color: CoreonColors.cyan)
                        StatCard(label: "Energia média", value: String(format: "%.1f", avgEnergy), icon: "bolt.fill", color: CoreonColors.amber)
                        StatCard(label: "Check-ins", value: "\(studentVM.checkins.count)", icon: "calendar.badge.checkmark", color: CoreonColors.violet)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.md)

                    // Adherence bar
                    VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                        Text("Taxa de adesão")
                            .font(CoreonFonts.semibold(16))
                            .foregroundColor(CoreonColors.textPrimary)

                        CoreonCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("\(completedWorkouts.count) de \(totalWorkouts) treinos concluídos")
                                        .font(CoreonFonts.regular(13))
                                        .foregroundColor(CoreonColors.textSecondary)
                                    Spacer()
                                    Text(String(format: "%.0f%%", adherenceRate))
                                        .font(CoreonFonts.bold(18))
                                        .foregroundColor(adherenceColor)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(CoreonColors.border)
                                            .frame(height: 10)
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(adherenceColor)
                                            .frame(width: geo.size.width * CGFloat(adherenceRate / 100), height: 10)
                                            .animation(.spring(), value: adherenceRate)
                                    }
                                }
                                .frame(height: 10)
                            }
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    // Recent check-ins
                    if !studentVM.checkins.isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Check-ins recentes")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)

                            ForEach(studentVM.checkins.prefix(5)) { checkin in
                                CheckinCard(checkin: checkin)
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

    private var adherenceColor: Color {
        if adherenceRate >= 80 { return CoreonColors.primary }
        if adherenceRate >= 50 { return CoreonColors.amber }
        return CoreonColors.danger
    }
}

struct CheckinCard: View {
    let checkin: DailyCheckin

    var body: some View {
        CoreonCard(padding: 14) {
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    if let date = checkin.checkinDate {
                        Text(date.formatted(.dateTime.day()))
                            .font(CoreonFonts.bold(18))
                            .foregroundColor(CoreonColors.primary)
                        Text(date.formatted(.dateTime.month(.abbreviated)))
                            .font(CoreonFonts.regular(11))
                            .foregroundColor(CoreonColors.textMuted)
                    }
                }
                .frame(width: 36)

                Divider()

                HStack(spacing: 20) {
                    if let v = checkin.energyLevel {
                        MetricPill(icon: "bolt.fill", value: v, max: 10, color: CoreonColors.amber)
                    }
                    if let v = checkin.sleepQuality {
                        MetricPill(icon: "moon.fill", value: v, max: 10, color: CoreonColors.cyan)
                    }
                    if let v = checkin.mood {
                        MetricPill(icon: "heart.fill", value: v, max: 10, color: CoreonColors.rose)
                    }
                    if let v = checkin.muscleSoreness {
                        MetricPill(icon: "figure.flexibility", value: v, max: 10, color: CoreonColors.violet)
                    }
                }
                Spacer()
            }
        }
    }
}

private struct MetricPill: View {
    let icon: String
    let value: Int
    let max: Int
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text("\(value)")
                .font(CoreonFonts.semibold(13))
                .foregroundColor(CoreonColors.textPrimary)
        }
    }
}

private let CoreonColors_rose = Color(hex: "#f43f5e")
