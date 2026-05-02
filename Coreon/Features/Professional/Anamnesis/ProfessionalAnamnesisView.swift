import SwiftUI

struct ProfessionalAnamnesisView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var proVM: ProfessionalViewModel
    @State private var templates: [AnamnesisTemplate] = []
    @State private var responses: [ClientAnamnesisResponse] = []
    @State private var isLoading = true
    @State private var selectedTab = 0
    @State private var showCreateTemplate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented control
                Picker("", selection: $selectedTab) {
                    Text("Templates").tag(0)
                    Text("Respostas").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(CoreonSpacing.lg)
                .background(Color.white)

                if isLoading {
                    LoadingView()
                } else if selectedTab == 0 {
                    templatesList
                } else {
                    responsesList
                }
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Anamneses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showCreateTemplate = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(CoreonColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateTemplate) {
                CreateAnamnesisTemplateView { _ in
                    Task { await loadData() }
                    showCreateTemplate = false
                }
            }
            .task { await loadData() }
            .refreshable { await loadData() }
        }
    }

    private var templatesList: some View {
        Group {
            if templates.isEmpty {
                EmptyStateView(
                    icon: "doc.badge.plus",
                    title: "Nenhum template",
                    message: "Crie templates de anamnese para enviar aos clientes.",
                    action: { showCreateTemplate = true },
                    actionLabel: "Criar template"
                )
            } else {
                List(templates) { template in
                    NavigationLink(destination: AnamnesisTemplateDetailView(template: template, clients: proVM.clients)) {
                        AnamnesisTemplateRow(template: template)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(.plain)
                .background(CoreonColors.background)
            }
        }
    }

    private var responsesList: some View {
        Group {
            if responses.isEmpty {
                EmptyStateView(icon: "tray", title: "Nenhuma resposta", message: "As respostas dos clientes aparecerão aqui.")
            } else {
                List(responses) { response in
                    AnamnesisResponseRow(response: response, clients: proVM.clients)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(.plain)
                .background(CoreonColors.background)
            }
        }
    }

    private func loadData() async {
        guard let email = authManager.currentUser?.email else { return }
        isLoading = true; defer { isLoading = false }
        async let tTask: [AnamnesisTemplate] = Base44Client.shared.entities("AnamnesisTemplate").filter(["created_by": email])
        async let rTask: [ClientAnamnesisResponse] = Base44Client.shared.entities("ClientAnamnesisResponse").list()
        let (t, r) = (try? await (tTask, rTask)) ?? ([], [])
        templates = t
        responses = r
    }
}

struct AnamnesisTemplateRow: View {
    let template: AnamnesisTemplate
    var body: some View {
        CoreonCard(padding: 14) {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 22))
                    .foregroundColor(CoreonColors.violet)
                    .frame(width: 44, height: 44)
                    .background(CoreonColors.violet.opacity(0.1))
                    .cornerRadius(12)
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name ?? "Template")
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack(spacing: 6) {
                        if let domain = template.domain {
                            CoreonBadge(text: domain, color: CoreonColors.violet)
                        }
                        if let sections = template.sections {
                            Text("\(sections.count) seções")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(CoreonColors.textMuted)
            }
        }
    }
}

struct AnamnesisResponseRow: View {
    let response: ClientAnamnesisResponse
    let clients: [Client]

    var clientName: String {
        guard let email = response.clientEmail else { return "Cliente" }
        return clients.first { $0.email == email }?.fullName ?? email
    }

    var body: some View {
        CoreonCard(padding: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(CoreonColors.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(clientName.prefix(1)))
                            .font(CoreonFonts.bold(18))
                            .foregroundColor(CoreonColors.primary)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(clientName)
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    if let date = response.submissionDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(CoreonFonts.regular(12))
                            .foregroundColor(CoreonColors.textMuted)
                    }
                }
                Spacer()
                CoreonBadge(
                    text: response.status == "reviewed" ? "Revisado" : "Pendente",
                    color: response.status == "reviewed" ? CoreonColors.primary : CoreonColors.amber
                )
            }
        }
    }
}

struct AnamnesisTemplateDetailView: View {
    let template: AnamnesisTemplate
    let clients: [Client]
    @State private var showSendSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CoreonSpacing.xl) {
                CoreonCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(template.name ?? "Template")
                            .font(CoreonFonts.bold(20))
                        HStack(spacing: 8) {
                            if let domain = template.domain {
                                CoreonBadge(text: domain, color: CoreonColors.violet)
                            }
                            if let desc = template.description {
                                Text(desc).font(CoreonFonts.regular(13)).foregroundColor(CoreonColors.textMuted)
                            }
                        }
                    }
                }
                .padding(.horizontal, CoreonSpacing.xl)

                if let sections = template.sections {
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title ?? "Seção")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                                .padding(.horizontal, CoreonSpacing.xl)
                            ForEach(section.questions ?? []) { q in
                                CoreonCard(padding: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: questionIcon(q.type))
                                            .font(.system(size: 14))
                                            .foregroundColor(CoreonColors.violet)
                                            .frame(width: 28, height: 28)
                                            .background(CoreonColors.violet.opacity(0.1))
                                            .cornerRadius(8)
                                        Text(q.questionText ?? "")
                                            .font(CoreonFonts.regular(14))
                                            .foregroundColor(CoreonColors.textPrimary)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, CoreonSpacing.xl)
                            }
                        }
                    }
                }

                CoreonButton("Enviar para clientes") { showSendSheet = true }
                    .padding(.horizontal, CoreonSpacing.xl)
            }
            .padding(.vertical, CoreonSpacing.xl)
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationTitle("Template")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSendSheet) {
            SendAnamnesisSheet(template: template, clients: clients)
        }
    }

    private func questionIcon(_ type: String?) -> String {
        switch type {
        case "text", "textarea": return "text.alignleft"
        case "number": return "number"
        case "select", "radio": return "circle.fill"
        case "multiselect", "checkbox": return "checkmark.square"
        case "date": return "calendar"
        default: return "questionmark"
        }
    }
}

struct SendAnamnesisSheet: View {
    let template: AnamnesisTemplate
    let clients: [Client]
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedEmails: Set<String> = []
    @State private var message = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(clients) { client in
                    HStack {
                        Image(systemName: selectedEmails.contains(client.email) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedEmails.contains(client.email) ? CoreonColors.primary : CoreonColors.textMuted)
                        Text(client.fullName ?? client.email)
                            .font(CoreonFonts.medium(15))
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedEmails.contains(client.email) {
                            selectedEmails.remove(client.email)
                        } else {
                            selectedEmails.insert(client.email)
                        }
                    }
                    .listRowBackground(Color.white)
                }
                .listStyle(.plain)

                VStack(spacing: 12) {
                    CoreonTextField(placeholder: "Mensagem para o cliente (opcional)", text: $message)
                    CoreonButton("Enviar para \(selectedEmails.count) cliente(s)", isLoading: isSending) {
                        Task { await send() }
                    }
                    .disabled(selectedEmails.isEmpty)
                }
                .padding(CoreonSpacing.xl)
                .background(Color.white)
            }
            .navigationTitle("Enviar anamnese")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func send() async {
        guard !selectedEmails.isEmpty, let templateId = template.id as? String,
              let myEmail = authManager.currentUser?.email else { return }
        isSending = true; defer { isSending = false }
        let assignments = selectedEmails.map { email -> [String: Any] in
            [
                "template_id": template.id,
                "client_email": email,
                "assigned_by": myEmail,
                "assigned_date": ISO8601DateFormatter().string(from: Date()),
                "domain": template.domain ?? "fitness",
                "status": "pending",
                "message": message.isEmpty ? "Você tem uma nova anamnese para preencher!" : message
            ]
        }
        let _: [AnamnesisAssignment]? = try? await Base44Client.shared.entities("AnamnesisAssignment").bulkCreate(assignments)
        dismiss()
    }
}

struct CreateAnamnesisTemplateView: View {
    let onSave: (AnamnesisTemplate) -> Void
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var domain = "fitness"
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Nome do template *") {
                        CoreonTextField(placeholder: "Ex: Anamnese Inicial", text: $name)
                    }
                    CoreonLabeledField("Descrição") {
                        CoreonTextField(placeholder: "Descreva o objetivo...", text: $description)
                    }
                    CoreonLabeledField("Domínio") {
                        Picker("Domínio", selection: $domain) {
                            Text("Fitness").tag("fitness")
                            Text("Nutrição").tag("nutrition")
                        }
                        .pickerStyle(.segmented)
                    }
                    CoreonButton("Criar template", isLoading: isLoading) {
                        Task { await save() }
                    }
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Novo Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        guard !name.isEmpty else { return }
        isLoading = true; defer { isLoading = false }
        let data: [String: Any] = ["name": name, "description": description, "domain": domain, "created_by": authManager.currentUser?.email ?? ""]
        let t: AnamnesisTemplate? = try? await Base44Client.shared.entities("AnamnesisTemplate").create(data)
        if let t = t { onSave(t) }
    }
}
