import SwiftUI

struct StudentMessagesView: View {
    @EnvironmentObject var studentVM: StudentViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var newMessage = ""
    @State private var isSending = false

    var professionalMessages: [Message] {
        studentVM.messages.sorted { ($0.createdDate ?? .distantPast) < ($1.createdDate ?? .distantPast) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if professionalMessages.isEmpty {
                    EmptyStateView(
                        icon: "message",
                        title: "Nenhuma mensagem",
                        message: "Suas mensagens com o profissional aparecerão aqui."
                    )
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(professionalMessages) { msg in
                                    MessageBubble(
                                        message: msg,
                                        isFromMe: msg.fromEmail == authManager.currentUser?.email
                                    )
                                    .id(msg.id)
                                }
                            }
                            .padding(CoreonSpacing.lg)
                        }
                        .onChange(of: professionalMessages.count) { _ in
                            if let last = professionalMessages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }
                }

                // Input
                HStack(spacing: 10) {
                    TextField("Mensagem...", text: $newMessage)
                        .font(CoreonFonts.regular(15))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(CoreonColors.background)
                        .cornerRadius(CoreonRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: CoreonRadius.pill)
                                .stroke(CoreonColors.border, lineWidth: 1)
                        )

                    Button {
                        Task { await sendMessage() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(newMessage.isEmpty ? CoreonColors.textMuted : CoreonColors.cyan)
                            .cornerRadius(20)
                    }
                    .disabled(newMessage.isEmpty || isSending)
                }
                .padding(.horizontal, CoreonSpacing.lg)
                .padding(.vertical, CoreonSpacing.md)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Mensagens")
        }
    }

    private func sendMessage() async {
        guard !newMessage.isEmpty,
              let myEmail = authManager.currentUser?.email else { return }
        let text = newMessage
        newMessage = ""
        isSending = true
        defer { isSending = false }
        do {
            let _: Message = try await Base44Client.shared.entities("Message").create([
                "from_email": myEmail,
                "content": text,
                "created_date": ISO8601DateFormatter().string(from: Date())
            ])
            await studentVM.load(userEmail: myEmail)
        } catch {}
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromMe: Bool

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.content ?? "")
                    .font(CoreonFonts.regular(14))
                    .foregroundColor(isFromMe ? .white : CoreonColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isFromMe ? CoreonColors.cyan : Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.05), radius: 3)

                if let date = message.createdDate {
                    Text(date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 10))
                        .foregroundColor(CoreonColors.textMuted)
                }
            }
            if !isFromMe { Spacer(minLength: 60) }
        }
    }
}
