import SwiftUI

struct ProfessionalMessagesListView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var proVM: ProfessionalViewModel
    @State private var conversations: [Conversation] = []
    @State private var isLoading = true

    var body: some View {
        AsyncContentView(isLoading: isLoading) {
            if conversations.isEmpty {
                EmptyStateView(icon: "message", title: "Nenhuma conversa", message: "Suas mensagens com clientes aparecerão aqui.")
            } else {
                List(conversations) { conv in
                    NavigationLink(destination: ClientMessagesView(clientEmail: conv.otherUserEmail).environmentObject(authManager)) {
                        ConversationRow(conversation: conv)
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
        .navigationTitle("Mensagens")
        .task { await loadConversations() }
    }

    private func loadConversations() async {
        guard let myEmail = authManager.currentUser?.email else { return }
        isLoading = true; defer { isLoading = false }
        let sent: [Message] = (try? await Base44Client.shared.entities("Message").filter(["from_email": myEmail])) ?? []
        let recv: [Message] = (try? await Base44Client.shared.entities("Message").filter(["to_email": myEmail])) ?? []
        var convMap: [String: Conversation] = [:]
        for msg in sent + recv {
            let other = msg.fromEmail == myEmail ? (msg.toEmail ?? "") : (msg.fromEmail ?? "")
            if other.isEmpty { continue }
            let clientName = proVM.clients.first { $0.email == other }?.fullName ?? other
            var conv = convMap[other] ?? Conversation(id: other, otherUserEmail: other, otherUserName: clientName, lastMessage: nil, lastMessageDate: nil, unreadCount: 0, messages: [])
            conv.messages.append(msg)
            if let date = msg.createdDate, (conv.lastMessageDate == nil || date > conv.lastMessageDate!) {
                conv.lastMessage = msg.content
                conv.lastMessageDate = date
            }
            if msg.toEmail == myEmail && msg.read == false { conv.unreadCount += 1 }
            convMap[other] = conv
        }
        conversations = convMap.values.sorted { ($0.lastMessageDate ?? .distantPast) > ($1.lastMessageDate ?? .distantPast) }
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        CoreonCard(padding: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(CoreonColors.primary.opacity(0.15))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(conversation.otherUserName?.prefix(1) ?? conversation.otherUserEmail.prefix(1)))
                            .font(CoreonFonts.bold(18))
                            .foregroundColor(CoreonColors.primary)
                    )
                    .overlay(
                        Group {
                            if conversation.unreadCount > 0 {
                                Circle()
                                    .fill(CoreonColors.danger)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Text("\(conversation.unreadCount)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 16, y: -16)
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(conversation.otherUserName ?? conversation.otherUserEmail)
                        .font(CoreonFonts.semibold(15))
                        .foregroundColor(CoreonColors.textPrimary)
                    Text(conversation.lastMessage ?? "")
                        .font(CoreonFonts.regular(13))
                        .foregroundColor(CoreonColors.textMuted)
                        .lineLimit(1)
                }

                Spacer()

                if let date = conversation.lastMessageDate {
                    Text(date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 11))
                        .foregroundColor(CoreonColors.textMuted)
                }
            }
        }
    }
}
