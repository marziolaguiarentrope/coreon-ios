import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var studentVM: StudentViewModel

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Bom dia" }
        if hour < 18 { return "Boa tarde" }
        return "Boa noite"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(greeting)!")
                                .font(CoreonFonts.regular(14))
                                .foregroundColor(CoreonColors.textMuted)
                            Text(authManager.currentUser?.fullName?.components(separatedBy: " ").first ?? "Atleta")
                                .font(CoreonFonts.bold(24))
                                .foregroundColor(CoreonColors.textPrimary)
                        }
                        Spacer()
                        Circle()
                            .fill(CoreonColors.cyan.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(authManager.currentUser?.fullName?.prefix(1) ?? "A"))
                                    .font(CoreonFonts.bold(18))
                                    .foregroundColor(CoreonColors.cyan)
                            )
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.lg)

                    // Stats row
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(label: "Treinos", value: "\(studentVM.workouts.count)", icon: "dumbbell.fill", color: CoreonColors.cyan)
                        StatCard(label: "Check-ins", value: "\(studentVM.checkins.count)", icon: "checkmark.circle.fill", color: CoreonColors.primary)
                        StatCard(label: "Mensagens", value: "\(studentVM.messages.filter { $0.read == false }.count)", icon: "message.fill", color: CoreonColors.violet)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    // Next workout
                    if let nextWorkout = studentVM.workouts.first(where: { $0.status != "completed" }) {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Próximo treino")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)

                            NavigationLink(destination: StudentWorkoutDetailView(workout: nextWorkout)) {
                                CoreonCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(nextWorkout.workoutName ?? "Treino")
                                                .font(CoreonFonts.semibold(16))
                                                .foregroundColor(CoreonColors.textPrimary)
                                            if let modality = nextWorkout.modality {
                                                CoreonBadge(text: modality, color: CoreonColors.cyan)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(CoreonColors.textMuted)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }

                    // Upcoming appointments
                    if !studentVM.appointments.isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Próximos agendamentos")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)

                            ForEach(studentVM.appointments.prefix(2)) { apt in
                                CoreonCard {
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(CoreonColors.primary.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Image(systemName: "calendar")
                                                    .foregroundColor(CoreonColors.primary)
                                            )
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(apt.title ?? "Consulta")
                                                .font(CoreonFonts.semibold(14))
                                                .foregroundColor(CoreonColors.textPrimary)
                                            if let date = apt.scheduledDate {
                                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                                    .font(CoreonFonts.regular(12))
                                                    .foregroundColor(CoreonColors.textMuted)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }

                    // Recent check-ins
                    if !studentVM.checkins.isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Check-ins recentes")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)

                            ForEach(studentVM.checkins.prefix(3)) { checkin in
                                CoreonCard {
                                    HStack(spacing: 16) {
                                        if let date = checkin.checkinDate {
                                            VStack(spacing: 2) {
                                                Text(date.formatted(.dateTime.day()))
                                                    .font(CoreonFonts.bold(20))
                                                    .foregroundColor(CoreonColors.primary)
                                                Text(date.formatted(.dateTime.month(.abbreviated)))
                                                    .font(CoreonFonts.regular(11))
                                                    .foregroundColor(CoreonColors.textMuted)
                                            }
                                            .frame(width: 40)
                                        }
                                        Divider()
                                        HStack(spacing: 16) {
                                            CheckinStat(icon: "bolt.fill", value: checkin.energyLevel, color: CoreonColors.amber)
                                            CheckinStat(icon: "moon.fill", value: checkin.sleepQuality, color: CoreonColors.cyan)
                                            CheckinStat(icon: "heart.fill", value: checkin.mood, color: CoreonColors.rose)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                await studentVM.load(userEmail: authManager.currentUser?.email ?? "")
            }
        }
    }
}

private struct CheckinStat: View {
    let icon: String
    let value: Int?
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value.map { "\($0)" } ?? "-")
                .font(CoreonFonts.semibold(13))
                .foregroundColor(CoreonColors.textPrimary)
        }
    }
}
