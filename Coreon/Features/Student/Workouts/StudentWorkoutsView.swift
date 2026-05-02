import SwiftUI

struct StudentWorkoutsView: View {
    @EnvironmentObject var studentVM: StudentViewModel
    @State private var filter: WorkoutFilter = .all

    enum WorkoutFilter: String, CaseIterable {
        case all = "Todos"
        case pending = "Pendentes"
        case completed = "Concluídos"
    }

    var filtered: [Workout] {
        switch filter {
        case .all: return studentVM.workouts
        case .pending: return studentVM.workouts.filter { $0.status != "completed" }
        case .completed: return studentVM.workouts.filter { $0.status == "completed" }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(WorkoutFilter.allCases, id: \.self) { f in
                            Button(f.rawValue) { filter = f }
                                .font(CoreonFonts.semibold(13))
                                .foregroundColor(filter == f ? .white : CoreonColors.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(filter == f ? CoreonColors.cyan : CoreonColors.border.opacity(0.5))
                                .cornerRadius(CoreonRadius.pill)
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.vertical, CoreonSpacing.md)
                }

                if studentVM.isLoading {
                    LoadingView()
                } else if filtered.isEmpty {
                    EmptyStateView(
                        icon: "dumbbell",
                        title: "Nenhum treino",
                        message: "Seus treinos atribuídos pelo profissional aparecerão aqui."
                    )
                } else {
                    List(filtered) { workout in
                        NavigationLink(destination: StudentWorkoutDetailView(workout: workout)) {
                            WorkoutRow(workout: workout)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .listStyle(.plain)
                    .background(CoreonColors.background)
                }
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Treinos")
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout

    var statusColor: Color {
        switch workout.status {
        case "completed": return CoreonColors.primary
        case "in_progress": return CoreonColors.amber
        default: return CoreonColors.textMuted
        }
    }

    var statusLabel: String {
        switch workout.status {
        case "completed": return "Concluído"
        case "in_progress": return "Em andamento"
        default: return "Pendente"
        }
    }

    var body: some View {
        CoreonCard {
            HStack(spacing: CoreonSpacing.md) {
                RoundedRectangle(cornerRadius: CoreonRadius.md)
                    .fill(CoreonColors.cyan.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: modalityIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(CoreonColors.cyan)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.workoutName ?? "Treino")
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack(spacing: 8) {
                        if let modality = workout.modality {
                            Text(modality)
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                        if let date = workout.workoutDate {
                            Text("•")
                                .foregroundColor(CoreonColors.textMuted)
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }

                Spacer()

                CoreonBadge(text: statusLabel, color: statusColor)
            }
        }
    }

    private var modalityIcon: String {
        switch workout.modality?.lowercased() {
        case "natação", "swim": return "figure.pool.swim"
        case "corrida", "running": return "figure.run"
        case "musculação", "strength": return "dumbbell.fill"
        case "yoga": return "figure.mind.and.body"
        case "ciclismo", "cycling": return "figure.outdoor.cycle"
        default: return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Workout Detail
struct StudentWorkoutDetailView: View {
    let workout: Workout
    @State private var showLogSession = false

    var body: some View {
        ScrollView {
            VStack(spacing: CoreonSpacing.xl) {
                // Header card
                CoreonCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.workoutName ?? "Treino")
                                    .font(CoreonFonts.bold(20))
                                    .foregroundColor(CoreonColors.textPrimary)
                                if let modality = workout.modality {
                                    CoreonBadge(text: modality, color: CoreonColors.cyan)
                                }
                            }
                            Spacer()
                            if let date = workout.workoutDate {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(date.formatted(.dateTime.day().month()))
                                        .font(CoreonFonts.semibold(14))
                                        .foregroundColor(CoreonColors.textPrimary)
                                    Text(date.formatted(.dateTime.year()))
                                        .font(CoreonFonts.regular(12))
                                        .foregroundColor(CoreonColors.textMuted)
                                }
                            }
                        }
                        if let notes = workout.notes, !notes.isEmpty {
                            Text(notes)
                                .font(CoreonFonts.regular(13))
                                .foregroundColor(CoreonColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, CoreonSpacing.xl)

                // Exercises
                if let exercises = workout.exercises, !exercises.isEmpty {
                    VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                        Text("Exercícios")
                            .font(CoreonFonts.semibold(16))
                            .foregroundColor(CoreonColors.textPrimary)
                            .padding(.horizontal, CoreonSpacing.xl)

                        ForEach(exercises) { entry in
                            ExerciseEntryRow(entry: entry)
                                .padding(.horizontal, CoreonSpacing.xl)
                        }
                    }
                }

                // Log session button
                if workout.status != "completed" {
                    CoreonButton("Registrar conclusão") {
                        showLogSession = true
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                }
            }
            .padding(.vertical, CoreonSpacing.xl)
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationTitle("Detalhe do Treino")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExerciseEntryRow: View {
    let entry: WorkoutExerciseEntry

    var body: some View {
        CoreonCard(padding: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(CoreonColors.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(entry.order ?? 0 + 1)")
                            .font(CoreonFonts.bold(14))
                            .foregroundColor(CoreonColors.primary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.exerciseName ?? "Exercício")
                        .font(CoreonFonts.semibold(14))
                        .foregroundColor(CoreonColors.textPrimary)

                    HStack(spacing: 12) {
                        if let sets = entry.sets {
                            Label("\(sets) séries", systemImage: "repeat")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                        if let reps = entry.reps {
                            Label(reps, systemImage: "arrow.trianglehead.2.clockwise")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                        if let weight = entry.weight {
                            Label(weight, systemImage: "scalemass")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
