import SwiftUI

struct AutonomousHomeView: View {
    @EnvironmentObject var autonomousVM: AutonomousViewModel
    @EnvironmentObject var authManager: AuthManager

    var greeting: String {
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
                    ZStack(alignment: .bottom) {
                        LinearGradient.autonomousGradient
                            .frame(height: 200)
                            .cornerRadius(CoreonRadius.xl)

                        VStack(spacing: CoreonSpacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(greeting)!")
                                        .font(CoreonFonts.regular(14))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(authManager.currentUser?.fullName?.components(separatedBy: " ").first ?? "Atleta")
                                        .font(CoreonFonts.bold(26))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                // XP badge
                                VStack(spacing: 2) {
                                    Text("\(autonomousVM.xp)")
                                        .font(CoreonFonts.bold(20))
                                        .foregroundColor(.white)
                                    Text("XP")
                                        .font(CoreonFonts.regular(11))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(CoreonRadius.lg)
                            }

                            // Stats row
                            HStack(spacing: 0) {
                                AutoHomeStat(value: "\(autonomousVM.streak)", label: "Streak", icon: "flame.fill", color: CoreonColors.amber)
                                Divider().background(Color.white.opacity(0.2)).frame(height: 30)
                                AutoHomeStat(value: "\(autonomousVM.completedWorkouts)", label: "Treinos", icon: "dumbbell.fill", color: .white)
                                Divider().background(Color.white.opacity(0.2)).frame(height: 30)
                                AutoHomeStat(value: "\(autonomousVM.checkins.count)", label: "Check-ins", icon: "checkmark.circle.fill", color: CoreonColors.primary)
                            }
                            .padding(CoreonSpacing.md)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(CoreonRadius.lg)
                        }
                        .padding(CoreonSpacing.lg)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.lg)

                    // Today's workout
                    if let todayWorkout = autonomousVM.workoutPlan.first(where: { !$0.completed }) {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Treino de hoje")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)

                            CoreonCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(todayWorkout.dayName)
                                            .font(CoreonFonts.bold(18))
                                            .foregroundColor(CoreonColors.textPrimary)
                                        Spacer()
                                        CoreonBadge(text: "\(todayWorkout.exercises.count) exercícios", color: CoreonColors.violet)
                                    }
                                    ForEach(todayWorkout.exercises.prefix(3)) { e in
                                        HStack {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(CoreonColors.textMuted)
                                                .font(.system(size: 14))
                                            Text(e.exerciseName ?? "")
                                                .font(CoreonFonts.regular(13))
                                                .foregroundColor(CoreonColors.textSecondary)
                                            Spacer()
                                            if let sets = e.sets, let reps = e.reps {
                                                Text("\(sets)x\(reps)")
                                                    .font(CoreonFonts.semibold(12))
                                                    .foregroundColor(CoreonColors.textMuted)
                                            }
                                        }
                                    }
                                    if todayWorkout.exercises.count > 3 {
                                        Text("+ \(todayWorkout.exercises.count - 3) exercícios")
                                            .font(CoreonFonts.regular(12))
                                            .foregroundColor(CoreonColors.textMuted)
                                    }

                                    CoreonButton("Iniciar treino", style: .secondary) {}
                                }
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }

                    // Daily check-in CTA
                    if autonomousVM.checkins.first?.checkinDate.map({ Calendar.current.isDateInToday($0) }) != true {
                        CheckinCTA()
                            .padding(.horizontal, CoreonSpacing.xl)
                    }

                    // Recent checkins
                    if !autonomousVM.checkins.isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Check-ins recentes")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                            ForEach(autonomousVM.checkins.prefix(3)) { c in
                                CheckinCard(checkin: c)
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

private struct AutoHomeStat: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            Text(value).font(CoreonFonts.bold(16)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CheckinCTA: View {
    @State private var energy = 5
    @State private var mood = 5
    @State private var showFull = false

    var body: some View {
        CoreonCard {
            VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(CoreonColors.violet)
                    Text("Check-in de hoje")
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    Spacer()
                }

                Text("Como você está se sentindo?")
                    .font(CoreonFonts.regular(13))
                    .foregroundColor(CoreonColors.textSecondary)

                HStack(spacing: CoreonSpacing.xl) {
                    VStack(spacing: 4) {
                        Text("Energia: \(energy)/10").font(CoreonFonts.regular(12)).foregroundColor(CoreonColors.textMuted)
                        Slider(value: Binding(get: { Double(energy) }, set: { energy = Int($0) }), in: 1...10, step: 1)
                            .accentColor(CoreonColors.amber)
                    }
                }

                CoreonButton("Registrar check-in", style: .secondary) { showFull = true }
            }
        }
        .sheet(isPresented: $showFull) {
            FullCheckinView()
        }
    }
}
