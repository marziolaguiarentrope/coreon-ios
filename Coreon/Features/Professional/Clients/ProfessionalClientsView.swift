import SwiftUI

struct ProfessionalClientsView: View {
    @EnvironmentObject var proVM: ProfessionalViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var search = ""
    @State private var showAddClient = false

    var filtered: [Client] {
        if search.isEmpty { return proVM.clients }
        return proVM.clients.filter {
            ($0.fullName ?? "").localizedCaseInsensitiveContains(search) ||
            $0.email.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(CoreonColors.textMuted)
                    TextField("Buscar cliente...", text: $search)
                        .font(CoreonFonts.regular(15))
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(CoreonRadius.md)
                .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border, lineWidth: 1))
                .padding(CoreonSpacing.lg)

                if proVM.isLoading {
                    LoadingView()
                } else if filtered.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "Nenhum cliente",
                        message: "Adicione clientes para começar a gerenciar treinos.",
                        action: { showAddClient = true },
                        actionLabel: "Adicionar cliente"
                    )
                } else {
                    List(filtered) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRow(client: client)
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
            .navigationTitle("Clientes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddClient = true } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 18))
                            .foregroundColor(CoreonColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView { _ in
                    Task { await proVM.load(userEmail: authManager.currentUser?.email ?? "") }
                    showAddClient = false
                }
            }
            .refreshable {
                await proVM.load(userEmail: authManager.currentUser?.email ?? "")
            }
        }
    }
}

struct ClientRow: View {
    let client: Client

    var body: some View {
        CoreonCard(padding: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(CoreonColors.primary.opacity(0.15))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(client.fullName?.prefix(1) ?? client.email.prefix(1)))
                            .font(CoreonFonts.bold(18))
                            .foregroundColor(CoreonColors.primary)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(client.fullName ?? client.email)
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    Text(client.email)
                        .font(CoreonFonts.regular(12))
                        .foregroundColor(CoreonColors.textMuted)
                    if let goal = client.goal {
                        CoreonBadge(text: goal, color: CoreonColors.primary)
                    }
                }

                Spacer()

                if let status = client.status {
                    Circle()
                        .fill(status == "active" ? CoreonColors.primary : CoreonColors.textMuted)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

// MARK: - Add Client View
struct AddClientView: View {
    @EnvironmentObject var authManager: AuthManager
    let onSave: (Client) -> Void
    @State private var email = ""
    @State private var fullName = ""
    @State private var goal = ""
    @State private var isLoading = false
    @State private var error: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    CoreonLabeledField("Email *") {
                        CoreonTextField(placeholder: "email@cliente.com", text: $email, keyboardType: .emailAddress, icon: "envelope")
                    }
                    CoreonLabeledField("Nome completo") {
                        CoreonTextField(placeholder: "Nome do cliente", text: $fullName, icon: "person")
                    }
                    CoreonLabeledField("Objetivo") {
                        CoreonTextField(placeholder: "Ex: Perda de peso, ganho muscular...", text: $goal, icon: "target")
                    }
                    if let error = error {
                        Text(error)
                            .font(CoreonFonts.regular(13))
                            .foregroundColor(CoreonColors.danger)
                    }
                    CoreonButton("Adicionar cliente", isLoading: isLoading) {
                        Task { await addClient() }
                    }
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Novo Cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func addClient() async {
        guard !email.isEmpty else { error = "Email obrigatório"; return }
        isLoading = true
        defer { isLoading = false }
        do {
            var data: [String: Any] = ["email": email, "assigned_trainer": authManager.currentUser?.email ?? ""]
            if !fullName.isEmpty { data["full_name"] = fullName }
            if !goal.isEmpty { data["goal"] = goal }
            let client: Client = try await Base44Client.shared.entities("Client").create(data)
            onSave(client)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
