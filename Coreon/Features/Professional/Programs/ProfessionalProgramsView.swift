import SwiftUI

struct ProfessionalProgramsView: View {
    @EnvironmentObject var proVM: ProfessionalViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showCreate = false
    @State private var selectedClient: Client? = nil

    var body: some View {
        NavigationStack {
            Group {
                if proVM.isLoading {
                    LoadingView()
                } else if proVM.programs.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet.clipboard",
                        title: "Nenhum programa",
                        message: "Crie programas de treino para seus clientes.",
                        action: { showCreate = true },
                        actionLabel: "Criar programa"
                    )
                } else {
                    List(proVM.programs) { program in
                        NavigationLink(destination: ProgramDetailView(program: program)) {
                            ProgramRow(program: program, clients: proVM.clients)
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
            .navigationTitle("Programas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(CoreonColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CreateProgramView(clients: proVM.clients) { _ in
                    Task { await proVM.load(userEmail: authManager.currentUser?.email ?? "") }
                    showCreate = false
                }
            }
            .refreshable {
                await proVM.load(userEmail: authManager.currentUser?.email ?? "")
            }
        }
    }
}

struct ProgramRow: View {
    let program: WorkoutProgram
    let clients: [Client]

    var clientName: String? {
        guard let email = program.clientEmail else { return nil }
        return clients.first { $0.email == email }?.fullName
    }

    var statusColor: Color {
        switch program.status {
        case "active": return CoreonColors.primary
        case "paused": return CoreonColors.amber
        case "completed": return CoreonColors.textMuted
        default: return CoreonColors.textMuted
        }
    }

    var body: some View {
        CoreonCard(padding: 14) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(CoreonColors.primary.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: program.programType == "group" ? "person.3.fill" : "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(CoreonColors.primary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(program.programName ?? "Programa")
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack(spacing: 6) {
                        if let name = clientName {
                            Label(name, systemImage: "person")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                        if let start = program.startDate {
                            Text("·")
                            Text(start)
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }

                Spacer()

                CoreonBadge(
                    text: program.status?.capitalized ?? "Ativo",
                    color: statusColor
                )
            }
        }
    }
}

struct ProgramDetailView: View {
    let program: WorkoutProgram
    @State private var workouts: [Workout] = []
    @State private var isLoading = true
    @State private var showAddWorkout = false

    var body: some View {
        VStack(spacing: 0) {
            // Program info card
            CoreonCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text(program.programName ?? "Programa")
                        .font(CoreonFonts.bold(20))
                    HStack(spacing: 12) {
                        if let start = program.startDate {
                            Label(start, systemImage: "calendar")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                        if let status = program.status {
                            CoreonBadge(text: status.capitalized, color: CoreonColors.primary)
                        }
                    }
                    if let notes = program.notes, !notes.isEmpty {
                        Text(notes)
                            .font(CoreonFonts.regular(13))
                            .foregroundColor(CoreonColors.textSecondary)
                    }
                }
            }
            .padding(CoreonSpacing.lg)

            if isLoading {
                LoadingView()
            } else if workouts.isEmpty {
                EmptyStateView(
                    icon: "dumbbell",
                    title: "Nenhum treino",
                    message: "Adicione treinos a este programa.",
                    action: { showAddWorkout = true },
                    actionLabel: "Adicionar treino"
                )
            } else {
                List(workouts) { w in
                    WorkoutRow(workout: w)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationTitle("Programa")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddWorkout = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await loadWorkouts() }
    }

    private func loadWorkouts() async {
        isLoading = true
        workouts = (try? await Base44Client.shared.entities("Workout").filter(["program_id": program.id])) ?? []
        isLoading = false
    }
}

struct CreateProgramView: View {
    let clients: [Client]
    let onSave: (WorkoutProgram) -> Void
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var programName = ""
    @State private var selectedClientEmail = ""
    @State private var programType = "individual"
    @State private var startDate = Date()
    @State private var endDate: Date? = nil
    @State private var status = "active"
    @State private var notes = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Nome do programa *") {
                        CoreonTextField(placeholder: "Ex: Programa Junho 2026", text: $programName, icon: "list.clipboard")
                    }

                    // Type selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo")
                            .font(CoreonFonts.semibold(13))
                            .foregroundColor(CoreonColors.textSecondary)
                        HStack(spacing: 8) {
                            ForEach(["individual", "group"], id: \.self) { t in
                                Button(t == "individual" ? "Individual" : "Coletivo") {
                                    programType = t
                                }
                                .font(CoreonFonts.semibold(13))
                                .foregroundColor(programType == t ? .white : CoreonColors.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(programType == t ? CoreonColors.primary : CoreonColors.border.opacity(0.5))
                                .cornerRadius(CoreonRadius.pill)
                            }
                            Spacer()
                        }
                    }

                    if programType == "individual" && !clients.isEmpty {
                        CoreonLabeledField("Cliente *") {
                            Picker("Selecione", selection: $selectedClientEmail) {
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

                    CoreonLabeledField("Data de início *") {
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 12)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }

                    CoreonLabeledField("Observações") {
                        TextEditor(text: $notes)
                            .font(CoreonFonts.regular(15))
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }

                    if let error = error {
                        Text(error).foregroundColor(CoreonColors.danger).font(CoreonFonts.regular(13))
                    }

                    CoreonButton("Salvar programa", isLoading: isLoading) {
                        Task { await save() }
                    }
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Novo Programa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        guard !programName.isEmpty else { error = "Nome obrigatório"; return }
        if programType == "individual" && selectedClientEmail.isEmpty {
            error = "Selecione um cliente"; return
        }
        isLoading = true; defer { isLoading = false }
        var data: [String: Any] = [
            "program_name": programName,
            "program_type": programType,
            "status": "active",
            "start_date": ISO8601DateFormatter().string(from: startDate),
            "created_by": authManager.currentUser?.email ?? ""
        ]
        if programType == "individual" { data["client_email"] = selectedClientEmail }
        if !notes.isEmpty { data["notes"] = notes }
        do {
            let prog: WorkoutProgram = try await Base44Client.shared.entities("WorkoutProgram").create(data)
            onSave(prog)
        } catch { self.error = error.localizedDescription }
    }
}
