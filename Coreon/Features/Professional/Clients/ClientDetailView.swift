import SwiftUI

struct ClientDetailView: View {
    let client: Client
    @EnvironmentObject var proVM: ProfessionalViewModel
    @State private var selectedTab = 0
    @State private var clientWorkouts: [Workout] = []
    @State private var clientPrograms: [WorkoutProgram] = []
    @State private var clientCheckins: [DailyCheckin] = []
    @State private var isLoading = true

    var tabs = ["Treinos", "Programas", "Check-ins", "Mensagens"]

    var body: some View {
        VStack(spacing: 0) {
            // Client header
            VStack(spacing: CoreonSpacing.md) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(CoreonColors.primary.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text(String(client.fullName?.prefix(1) ?? client.email.prefix(1)))
                                .font(CoreonFonts.bold(24))
                                .foregroundColor(CoreonColors.primary)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(client.fullName ?? client.email)
                            .font(CoreonFonts.bold(18))
                            .foregroundColor(CoreonColors.textPrimary)
                        Text(client.email)
                            .font(CoreonFonts.regular(13))
                            .foregroundColor(CoreonColors.textMuted)
                        if let goal = client.goal {
                            CoreonBadge(text: goal, color: CoreonColors.primary)
                        }
                    }
                    Spacer()
                }

                // Quick stats
                HStack(spacing: 12) {
                    MiniStat(value: "\(clientWorkouts.count)", label: "Treinos")
                    MiniStat(value: "\(clientPrograms.count)", label: "Programas")
                    MiniStat(value: "\(clientCheckins.count)", label: "Check-ins")
                    MiniStat(
                        value: "\(clientWorkouts.filter { $0.status == "completed" }.count)",
                        label: "Concluídos"
                    )
                }
            }
            .padding(CoreonSpacing.lg)
            .background(Color.white)

            // Tab picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(tabs.indices, id: \.self) { i in
                        Button(tabs[i]) { selectedTab = i }
                            .font(CoreonFonts.semibold(13))
                            .foregroundColor(selectedTab == i ? .white : CoreonColors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedTab == i ? CoreonColors.primary : Color.clear)
                            .cornerRadius(CoreonRadius.pill)
                    }
                }
                .padding(.horizontal, CoreonSpacing.lg)
                .padding(.vertical, 8)
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

            // Tab content
            if isLoading {
                LoadingView()
            } else {
                TabView(selection: $selectedTab) {
                    clientWorkoutsList.tag(0)
                    clientProgramsList.tag(1)
                    clientCheckinsList.tag(2)
                    ClientMessagesView(clientEmail: client.email).tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationTitle(client.fullName ?? "Cliente")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadClientData() }
    }

    private var clientWorkoutsList: some View {
        List(clientWorkouts) { w in
            WorkoutRow(workout: w)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .listStyle(.plain)
        .background(CoreonColors.background)
    }

    private var clientProgramsList: some View {
        List(clientPrograms) { p in
            CoreonCard(padding: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(p.programName ?? "Programa")
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack {
                        if let status = p.status {
                            CoreonBadge(text: status.capitalized, color: statusColor(p.status))
                        }
                        if let start = p.startDate {
                            Text("Início: \(start)")
                                .font(CoreonFonts.regular(12))
                                .foregroundColor(CoreonColors.textMuted)
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .listStyle(.plain)
        .background(CoreonColors.background)
    }

    private var clientCheckinsList: some View {
        List(clientCheckins) { c in
            CheckinCard(checkin: c)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .listStyle(.plain)
        .background(CoreonColors.background)
    }

    private func statusColor(_ s: String?) -> Color {
        switch s {
        case "active": return CoreonColors.primary
        case "paused": return CoreonColors.amber
        case "completed": return CoreonColors.textMuted
        default: return CoreonColors.textMuted
        }
    }

    private func loadClientData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let wTask: [Workout] = Base44Client.shared.entities("Workout").filter(["client_email": client.email])
            async let pTask: [WorkoutProgram] = Base44Client.shared.entities("WorkoutProgram").filter(["client_email": client.email])
            async let cTask: [DailyCheckin] = Base44Client.shared.entities("DailyCheckin").filter(["client_email": client.email])
            let (w, p, c) = try await (wTask, pTask, cTask)
            clientWorkouts = w
            clientPrograms = p
            clientCheckins = c
        } catch {}
    }
}

private struct MiniStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(CoreonFonts.bold(18))
                .foregroundColor(CoreonColors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(CoreonColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(CoreonColors.background)
        .cornerRadius(CoreonRadius.md)
    }
}

struct ClientMessagesView: View {
    let clientEmail: String
    @EnvironmentObject var authManager: AuthManager
    @State private var messages: [Message] = []
    @State private var newMessage = ""

    var body: some View {
        VStack {
            List(messages) { msg in
                MessageBubble(
                    message: msg,
                    isFromMe: msg.fromEmail == authManager.currentUser?.email
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

            HStack(spacing: 10) {
                TextField("Mensagem...", text: $newMessage)
                    .padding(10)
                    .background(CoreonColors.background)
                    .cornerRadius(CoreonRadius.pill)
                    .overlay(RoundedRectangle(cornerRadius: CoreonRadius.pill).stroke(CoreonColors.border))

                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(CoreonColors.primary)
                        .cornerRadius(20)
                }
                .disabled(newMessage.isEmpty)
            }
            .padding(CoreonSpacing.lg)
        }
        .task { await loadMessages() }
    }

    private func loadMessages() async {
        let sent: [Message] = (try? await Base44Client.shared.entities("Message").filter(["to_email": clientEmail])) ?? []
        let recv: [Message] = (try? await Base44Client.shared.entities("Message").filter(["from_email": clientEmail])) ?? []
        messages = (sent + recv).sorted { ($0.createdDate ?? .distantPast) < ($1.createdDate ?? .distantPast) }
    }

    private func send() async {
        guard !newMessage.isEmpty, let myEmail = authManager.currentUser?.email else { return }
        let text = newMessage; newMessage = ""
        let _: Message? = try? await Base44Client.shared.entities("Message").create([
            "from_email": myEmail, "to_email": clientEmail, "content": text,
            "created_date": ISO8601DateFormatter().string(from: Date())
        ])
        await loadMessages()
    }
}
