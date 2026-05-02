import SwiftUI

struct AutonomousWorkoutView: View {
    @EnvironmentObject var autonomousVM: AutonomousViewModel
    @State private var showLogActivity = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    if autonomousVM.workoutPlan.isEmpty {
                        EmptyStateView(
                            icon: "dumbbell",
                            title: "Nenhum plano gerado",
                            message: "Complete o onboarding para que a IA gere seu plano personalizado."
                        )
                    } else {
                        ForEach(autonomousVM.workoutPlan) { day in
                            WorkoutDayCard(day: day)
                        }
                    }
                }
                .padding(.horizontal, CoreonSpacing.xl)
                .padding(.vertical, CoreonSpacing.lg)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Meus Treinos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showLogActivity = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(CoreonColors.violet)
                    }
                }
            }
            .sheet(isPresented: $showLogActivity) {
                LogActivityView()
            }
        }
    }
}

struct WorkoutDayCard: View {
    let day: WorkoutDay

    var body: some View {
        CoreonCard {
            VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.dayName)
                            .font(CoreonFonts.bold(17))
                            .foregroundColor(CoreonColors.textPrimary)
                        Text("\(day.exercises.count) exercícios")
                            .font(CoreonFonts.regular(13))
                            .foregroundColor(CoreonColors.textMuted)
                    }
                    Spacer()
                    if day.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(CoreonColors.primary)
                    } else {
                        CoreonBadge(text: "Pendente", color: CoreonColors.violet)
                    }
                }

                Divider()

                ForEach(day.exercises) { exercise in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(day.completed ? CoreonColors.primary.opacity(0.15) : CoreonColors.border.opacity(0.5))
                            .frame(width: 8, height: 8)
                        Text(exercise.exerciseName ?? "Exercício")
                            .font(CoreonFonts.regular(14))
                            .foregroundColor(CoreonColors.textSecondary)
                        Spacer()
                        if let s = exercise.sets, let r = exercise.reps {
                            Text("\(s)x\(r)")
                                .font(CoreonFonts.semibold(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }

                if !day.completed {
                    CoreonButton("Iniciar treino", style: .secondary) {}
                }
            }
        }
    }
}

struct LogActivityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var activityType = "Treino"
    @State private var duration = ""
    @State private var notes = ""

    let activityTypes = ["Treino", "Corrida", "Caminhada", "Natação", "Ciclismo", "Yoga", "Outros"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Tipo de atividade") {
                        Picker("Tipo", selection: $activityType) {
                            ForEach(activityTypes, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 12).frame(height: 48)
                        .background(Color.white).cornerRadius(CoreonRadius.md)
                        .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }
                    CoreonLabeledField("Duração (minutos)") {
                        CoreonTextField(placeholder: "45", text: $duration, keyboardType: .numberPad, icon: "clock")
                    }
                    CoreonLabeledField("Notas") {
                        TextEditor(text: $notes)
                            .font(CoreonFonts.regular(15))
                            .frame(minHeight: 80)
                            .padding(8).background(Color.white).cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }
                    CoreonButton("Registrar atividade") { dismiss() }
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Registrar Atividade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
        }
    }
}
