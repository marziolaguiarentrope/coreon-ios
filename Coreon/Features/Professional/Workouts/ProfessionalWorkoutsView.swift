import SwiftUI

struct ProfessionalWorkoutsView: View {
    @EnvironmentObject var proVM: ProfessionalViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showBuilder = false

    var body: some View {
        NavigationStack {
            Group {
                if proVM.workouts.isEmpty {
                    EmptyStateView(
                        icon: "dumbbell",
                        title: "Nenhum treino",
                        message: "Crie treinos personalizados para seus clientes.",
                        action: { showBuilder = true },
                        actionLabel: "Criar treino"
                    )
                } else {
                    List(proVM.workouts) { workout in
                        NavigationLink(destination: WorkoutBuilderView(workout: workout, clients: proVM.clients) { _ in
                            Task { await proVM.load(userEmail: authManager.currentUser?.email ?? "") }
                        }) {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showBuilder = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(CoreonColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showBuilder) {
                WorkoutBuilderView(workout: nil, clients: proVM.clients) { _ in
                    Task { await proVM.load(userEmail: authManager.currentUser?.email ?? "") }
                    showBuilder = false
                }
            }
            .refreshable {
                await proVM.load(userEmail: authManager.currentUser?.email ?? "")
            }
        }
    }
}

// MARK: - Workout Builder
struct WorkoutBuilderView: View {
    let workout: Workout?
    let clients: [Client]
    let onSave: (Workout) -> Void

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: WorkoutBuilderViewModel

    init(workout: Workout?, clients: [Client], onSave: @escaping (Workout) -> Void) {
        self.workout = workout
        self.clients = clients
        self.onSave = onSave
        self._vm = StateObject(wrappedValue: WorkoutBuilderViewModel(workout: workout))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Nome do treino *") {
                        CoreonTextField(placeholder: "Ex: Treino A - Peito e Tríceps", text: $vm.workoutName, icon: "dumbbell")
                    }

                    if !clients.isEmpty {
                        CoreonLabeledField("Cliente") {
                            Picker("Selecione", selection: $vm.clientEmail) {
                                Text("Selecione um cliente").tag("")
                                ForEach(clients) { c in
                                    Text(c.fullName ?? c.email).tag(c.email)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 12)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                        }
                    }

                    CoreonLabeledField("Modalidade") {
                        Picker("Modalidade", selection: $vm.modality) {
                            ForEach(["Musculação", "Natação", "Corrida", "HIIT", "Yoga", "Funcional", "Ciclismo", "Pilates"], id: \.self) { m in
                                Text(m).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(CoreonRadius.md)
                        .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }

                    CoreonLabeledField("Data") {
                        DatePicker("", selection: $vm.workoutDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 12)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }

                    // Exercises section
                    VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                        HStack {
                            Text("Exercícios")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                            Spacer()
                            Button { vm.addExercise() } label: {
                                Label("Adicionar", systemImage: "plus")
                                    .font(CoreonFonts.semibold(13))
                                    .foregroundColor(CoreonColors.primary)
                            }
                        }

                        if vm.exercises.isEmpty {
                            Text("Nenhum exercício adicionado")
                                .font(CoreonFonts.regular(13))
                                .foregroundColor(CoreonColors.textMuted)
                                .frame(maxWidth: .infinity)
                                .padding(CoreonSpacing.xl)
                                .background(CoreonColors.border.opacity(0.3))
                                .cornerRadius(CoreonRadius.md)
                        } else {
                            ForEach(vm.exercises.indices, id: \.self) { i in
                                ExerciseBuilderRow(
                                    entry: $vm.exercises[i],
                                    index: i,
                                    onDelete: { vm.removeExercise(at: i) }
                                )
                            }
                        }
                    }

                    CoreonLabeledField("Observações") {
                        TextEditor(text: $vm.notes)
                            .font(CoreonFonts.regular(15))
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }

                    CoreonButton("Salvar treino", isLoading: vm.isLoading) {
                        Task { await save() }
                    }
                }
                .padding(CoreonSpacing.xl)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle(workout == nil ? "Novo Treino" : "Editar Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        guard let result = await vm.save(createdBy: authManager.currentUser?.email ?? "") else { return }
        onSave(result)
        dismiss()
    }
}

struct ExerciseBuilderRow: View {
    @Binding var entry: WorkoutExerciseEntry
    let index: Int
    let onDelete: () -> Void

    var body: some View {
        CoreonCard(padding: 12) {
            VStack(spacing: 10) {
                HStack {
                    Text("Exercício \(index + 1)")
                        .font(CoreonFonts.semibold(14))
                        .foregroundColor(CoreonColors.textPrimary)
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(CoreonColors.danger)
                    }
                }

                CoreonTextField(
                    placeholder: "Nome do exercício",
                    text: Binding(
                        get: { entry.exerciseName ?? "" },
                        set: { entry = WorkoutExerciseEntry(id: entry.id, exerciseId: entry.exerciseId, exerciseName: $0, sets: entry.sets, reps: entry.reps, weight: entry.weight, restSeconds: entry.restSeconds, rpe: entry.rpe, notes: entry.notes, order: entry.order, setDetails: entry.setDetails) }
                    )
                )

                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Séries").font(CoreonFonts.regular(11)).foregroundColor(CoreonColors.textMuted)
                        TextField("3", value: Binding(get: { entry.sets ?? 3 }, set: { v in
                            entry = WorkoutExerciseEntry(id: entry.id, exerciseId: entry.exerciseId, exerciseName: entry.exerciseName, sets: v, reps: entry.reps, weight: entry.weight, restSeconds: entry.restSeconds, rpe: entry.rpe, notes: entry.notes, order: entry.order, setDetails: entry.setDetails)
                        }), formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .padding(8)
                        .background(CoreonColors.background)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(CoreonColors.border))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reps").font(CoreonFonts.regular(11)).foregroundColor(CoreonColors.textMuted)
                        TextField("12", text: Binding(get: { entry.reps ?? "" }, set: { v in
                            entry = WorkoutExerciseEntry(id: entry.id, exerciseId: entry.exerciseId, exerciseName: entry.exerciseName, sets: entry.sets, reps: v, weight: entry.weight, restSeconds: entry.restSeconds, rpe: entry.rpe, notes: entry.notes, order: entry.order, setDetails: entry.setDetails)
                        }))
                        .padding(8)
                        .background(CoreonColors.background)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(CoreonColors.border))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Carga").font(CoreonFonts.regular(11)).foregroundColor(CoreonColors.textMuted)
                        TextField("20kg", text: Binding(get: { entry.weight ?? "" }, set: { v in
                            entry = WorkoutExerciseEntry(id: entry.id, exerciseId: entry.exerciseId, exerciseName: entry.exerciseName, sets: entry.sets, reps: entry.reps, weight: v, restSeconds: entry.restSeconds, rpe: entry.rpe, notes: entry.notes, order: entry.order, setDetails: entry.setDetails)
                        }))
                        .padding(8)
                        .background(CoreonColors.background)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(CoreonColors.border))
                    }
                }
            }
        }
    }
}

@MainActor
class WorkoutBuilderViewModel: ObservableObject {
    @Published var workoutName: String
    @Published var clientEmail: String
    @Published var modality: String
    @Published var workoutDate: Date
    @Published var notes: String
    @Published var exercises: [WorkoutExerciseEntry]
    @Published var isLoading = false

    private let existingId: String?

    init(workout: Workout?) {
        self.existingId = workout?.id
        self.workoutName = workout?.workoutName ?? ""
        self.clientEmail = workout?.clientEmail ?? ""
        self.modality = workout?.modality ?? "Musculação"
        self.workoutDate = workout?.workoutDate ?? Date()
        self.notes = workout?.notes ?? ""
        self.exercises = workout?.exercises ?? []
    }

    func addExercise() {
        exercises.append(WorkoutExerciseEntry(
            id: UUID().uuidString, exerciseId: nil, exerciseName: "",
            sets: 3, reps: "12", weight: "", restSeconds: 60,
            rpe: nil, notes: nil, order: exercises.count, setDetails: nil
        ))
    }

    func removeExercise(at index: Int) {
        exercises.remove(at: index)
    }

    func save(createdBy: String) async -> Workout? {
        guard !workoutName.isEmpty else { return nil }
        isLoading = true; defer { isLoading = false }
        var data: [String: Any] = [
            "workout_name": workoutName,
            "modality": modality,
            "workout_date": ISO8601DateFormatter().string(from: workoutDate),
            "created_by": createdBy,
            "status": "pending"
        ]
        if !clientEmail.isEmpty { data["client_email"] = clientEmail }
        if !notes.isEmpty { data["notes"] = notes }
        if let id = existingId {
            return try? await Base44Client.shared.entities("Workout").update(id: id, data)
        } else {
            return try? await Base44Client.shared.entities("Workout").create(data)
        }
    }
}
