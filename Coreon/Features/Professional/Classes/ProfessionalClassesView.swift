import SwiftUI

struct ProfessionalClassesView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var classes: [GroupClass] = []
    @State private var isLoading = true
    @State private var showCreate = false

    var body: some View {
        AsyncContentView(isLoading: isLoading) {
            if classes.isEmpty {
                EmptyStateView(
                    icon: "person.3",
                    title: "Nenhuma aula",
                    message: "Crie aulas em grupo para seus alunos.",
                    action: { showCreate = true },
                    actionLabel: "Criar aula"
                )
            } else {
                List(classes) { c in
                    ClassRow(groupClass: c)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(.plain)
                .background(CoreonColors.background)
            }
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationTitle("Aulas em grupo")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCreate = true } label: {
                    Image(systemName: "plus.circle.fill").foregroundColor(CoreonColors.primary)
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateClassView { _ in
                Task { await loadClasses() }
                showCreate = false
            }
        }
        .task { await loadClasses() }
    }

    private func loadClasses() async {
        guard let email = authManager.currentUser?.email else { return }
        isLoading = true
        classes = (try? await Base44Client.shared.entities("GroupClass").filter(["instructor_email": email])) ?? []
        isLoading = false
    }
}

struct ClassRow: View {
    let groupClass: GroupClass

    var body: some View {
        CoreonCard(padding: 14) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(CoreonColors.cyan.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 18))
                            .foregroundColor(CoreonColors.cyan)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(groupClass.title ?? "Aula")
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack(spacing: 8) {
                        if let date = groupClass.scheduledDate {
                            Label(date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                        if let max = groupClass.maxStudents {
                            Label("\(groupClass.enrolledCount ?? 0)/\(max)", systemImage: "person.fill")
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

struct CreateClassView: View {
    let onSave: (GroupClass) -> Void
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var scheduledDate = Date()
    @State private var durationMinutes = 60
    @State private var maxStudents = 10
    @State private var modality = ""
    @State private var location = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Título *") {
                        CoreonTextField(placeholder: "Ex: Yoga Avançado - Terça", text: $title)
                    }
                    CoreonLabeledField("Data e hora *") {
                        DatePicker("", selection: $scheduledDate)
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 12).frame(height: 48)
                            .background(Color.white).cornerRadius(CoreonRadius.md)
                            .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }
                    HStack(spacing: 12) {
                        CoreonLabeledField("Duração (min)") {
                            TextField("60", value: $durationMinutes, formatter: NumberFormatter())
                                .keyboardType(.numberPad).padding(12)
                                .background(Color.white).cornerRadius(CoreonRadius.md)
                                .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                        }
                        CoreonLabeledField("Máx. alunos") {
                            TextField("10", value: $maxStudents, formatter: NumberFormatter())
                                .keyboardType(.numberPad).padding(12)
                                .background(Color.white).cornerRadius(CoreonRadius.md)
                                .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                        }
                    }
                    CoreonLabeledField("Local") {
                        CoreonTextField(placeholder: "Academia, parque...", text: $location, icon: "mappin")
                    }
                    CoreonButton("Criar aula", isLoading: isLoading) {
                        Task { await save() }
                    }
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Nova Aula")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
            }
        }
    }

    private func save() async {
        guard !title.isEmpty else { return }
        isLoading = true; defer { isLoading = false }
        var data: [String: Any] = [
            "title": title,
            "scheduled_date": ISO8601DateFormatter().string(from: scheduledDate),
            "duration_minutes": durationMinutes,
            "max_students": maxStudents,
            "instructor_email": authManager.currentUser?.email ?? "",
            "enrolled_count": 0, "status": "scheduled"
        ]
        if !location.isEmpty { data["location"] = location }
        let c: GroupClass? = try? await Base44Client.shared.entities("GroupClass").create(data)
        if let c = c { onSave(c) }
    }
}
