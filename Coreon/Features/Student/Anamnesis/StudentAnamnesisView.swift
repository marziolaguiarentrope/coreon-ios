import SwiftUI

struct StudentAnamnesisView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var assignments: [AnamnesisAssignment] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            AsyncContentView(isLoading: isLoading) {
                if assignments.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "Nenhuma anamnese",
                        message: "Formulários de saúde enviados pelo seu profissional aparecerão aqui."
                    )
                } else {
                    List(assignments) { assignment in
                        AnamnesisAssignmentRow(assignment: assignment)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Anamneses")
            .task { await loadAssignments() }
        }
    }

    private func loadAssignments() async {
        guard let email = authManager.currentUser?.email else { return }
        isLoading = true
        defer { isLoading = false }
        assignments = (try? await Base44Client.shared.entities("AnamnesisAssignment").filter(["client_email": email])) ?? []
    }
}

struct AnamnesisAssignmentRow: View {
    let assignment: AnamnesisAssignment

    var statusColor: Color {
        switch assignment.status {
        case "completed": return CoreonColors.primary
        case "pending": return CoreonColors.amber
        default: return CoreonColors.textMuted
        }
    }

    var body: some View {
        CoreonCard {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 24))
                    .foregroundColor(CoreonColors.violet)
                    .frame(width: 44, height: 44)
                    .background(CoreonColors.violet.opacity(0.1))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.domain?.capitalized ?? "Anamnese")
                        .font(CoreonFonts.semibold(14))
                        .foregroundColor(CoreonColors.textPrimary)
                    if let msg = assignment.message {
                        Text(msg)
                            .font(CoreonFonts.regular(12))
                            .foregroundColor(CoreonColors.textMuted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                CoreonBadge(
                    text: assignment.status == "completed" ? "Respondido" : "Pendente",
                    color: statusColor
                )
            }
        }
        .padding(.horizontal, CoreonSpacing.xl)
        .padding(.vertical, 4)
    }
}
