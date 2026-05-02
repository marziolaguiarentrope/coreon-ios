import SwiftUI

struct ProfessionalFinancialView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var proVM: ProfessionalViewModel
    @State private var payments: [Payment] = []
    @State private var isLoading = true
    @State private var showAddPayment = false

    var pendingTotal: Double { payments.filter { $0.status == "pending" }.compactMap { $0.amount }.reduce(0, +) }
    var paidTotal: Double { payments.filter { $0.status == "paid" }.compactMap { $0.amount }.reduce(0, +) }

    var body: some View {
        AsyncContentView(isLoading: isLoading) {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Summary
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(label: "Recebido", value: formatCurrency(paidTotal), icon: "checkmark.circle.fill", color: CoreonColors.primary)
                        StatCard(label: "Pendente", value: formatCurrency(pendingTotal), icon: "clock.fill", color: CoreonColors.amber)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.md)

                    // Payments list
                    VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                        HStack {
                            Text("Pagamentos")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                            Spacer()
                            Button { showAddPayment = true } label: {
                                Label("Novo", systemImage: "plus")
                                    .font(CoreonFonts.semibold(13))
                                    .foregroundColor(CoreonColors.primary)
                            }
                        }

                        ForEach(payments) { payment in
                            PaymentRow(payment: payment, clients: proVM.clients)
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                }
                .padding(.bottom, 32)
            }
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationTitle("Financeiro")
        .sheet(isPresented: $showAddPayment) {
            AddPaymentView(clients: proVM.clients) { _ in
                Task { await loadPayments() }
                showAddPayment = false
            }
        }
        .task { await loadPayments() }
    }

    private func formatCurrency(_ value: Double) -> String {
        "R$ " + String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }

    private func loadPayments() async {
        guard let email = authManager.currentUser?.email else { return }
        isLoading = true
        payments = (try? await Base44Client.shared.entities("Payment").filter(["professional_email": email], sortBy: "-created_date")) ?? []
        isLoading = false
    }
}

struct PaymentRow: View {
    let payment: Payment
    let clients: [Client]

    var clientName: String {
        guard let email = payment.clientEmail else { return "Cliente" }
        return clients.first { $0.email == email }?.fullName ?? email
    }

    var statusColor: Color {
        switch payment.status {
        case "paid": return CoreonColors.primary
        case "pending": return CoreonColors.amber
        case "overdue": return CoreonColors.danger
        default: return CoreonColors.textMuted
        }
    }

    var body: some View {
        CoreonCard(padding: 14) {
            HStack(spacing: 12) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 18))
                    .foregroundColor(statusColor)
                    .frame(width: 40, height: 40)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(clientName)
                        .font(CoreonFonts.semibold(14))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack(spacing: 6) {
                        if let cat = payment.category {
                            Text(cat).font(CoreonFonts.regular(12)).foregroundColor(CoreonColors.textMuted)
                        }
                        if let due = payment.dueDate {
                            Text("· Venc: \(due)").font(CoreonFonts.regular(12)).foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let amount = payment.amount {
                        Text("R$ \(String(format: "%.0f", amount))")
                            .font(CoreonFonts.bold(15))
                            .foregroundColor(CoreonColors.textPrimary)
                    }
                    CoreonBadge(text: payment.status?.capitalized ?? "Pendente", color: statusColor)
                }
            }
        }
    }
}

struct AddPaymentView: View {
    let clients: [Client]
    let onSave: (Payment) -> Void
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var clientEmail = ""
    @State private var amount = ""
    @State private var category = "monthly"
    @State private var dueDate = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Cliente *") {
                        Picker("Selecione", selection: $clientEmail) {
                            Text("Selecione").tag("")
                            ForEach(clients) { c in Text(c.fullName ?? c.email).tag(c.email) }
                        }
                        .pickerStyle(.menu).padding(.horizontal, 12).frame(height: 48)
                        .background(Color.white).cornerRadius(CoreonRadius.md)
                        .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                    }
                    CoreonLabeledField("Valor (R$) *") {
                        CoreonTextField(placeholder: "150.00", text: $amount, keyboardType: .decimalPad, icon: "dollarsign.circle")
                    }
                    CoreonLabeledField("Categoria") {
                        Picker("Categoria", selection: $category) {
                            Text("Mensal").tag("monthly")
                            Text("Por sessão").tag("per_session")
                            Text("Pacote").tag("package")
                        }
                        .pickerStyle(.segmented)
                    }
                    CoreonLabeledField("Vencimento") {
                        CoreonTextField(placeholder: "DD/MM/AAAA", text: $dueDate, icon: "calendar")
                    }
                    CoreonButton("Registrar pagamento", isLoading: isLoading) {
                        Task { await save() }
                    }
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Novo Pagamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
        }
    }

    private func save() async {
        guard !clientEmail.isEmpty, let amountVal = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }
        isLoading = true; defer { isLoading = false }
        var data: [String: Any] = [
            "client_email": clientEmail,
            "professional_email": authManager.currentUser?.email ?? "",
            "amount": amountVal, "currency": "BRL", "category": category,
            "status": "pending", "created_date": ISO8601DateFormatter().string(from: Date())
        ]
        if !dueDate.isEmpty { data["due_date"] = dueDate }
        let p: Payment? = try? await Base44Client.shared.entities("Payment").create(data)
        if let p = p { onSave(p) }
    }
}
