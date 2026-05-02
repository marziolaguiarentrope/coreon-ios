import SwiftUI

struct AutonomousCoachView: View {
    @EnvironmentObject var autonomousVM: AutonomousViewModel
    @State private var inputText = ""
    @ScrollViewProxy var scrollProxy: ScrollViewProxy? = nil

    let quickPrompts = [
        "Estou cansado hoje, posso pular o treino?",
        "Como melhoro minha recuperação?",
        "Quais exercícios para perda de peso?",
        "Como ajustar minha alimentação?",
        "Preciso de motivação!"
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: CoreonSpacing.md) {
                                if autonomousVM.chatMessages.isEmpty {
                                    // Welcome state
                                    VStack(spacing: CoreonSpacing.xl) {
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient.autonomousGradient)
                                                .frame(width: 80, height: 80)
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 32, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        VStack(spacing: 8) {
                                            Text("Seu Coach IA")
                                                .font(CoreonFonts.bold(22))
                                                .foregroundColor(CoreonColors.textPrimary)
                                            Text("Tire dúvidas, peça motivação ou ajuda para ajustar seu plano.")
                                                .font(CoreonFonts.regular(14))
                                                .foregroundColor(CoreonColors.textMuted)
                                                .multilineTextAlignment(.center)
                                        }

                                        // Quick prompts
                                        VStack(spacing: 8) {
                                            ForEach(quickPrompts, id: \.self) { prompt in
                                                Button {
                                                    Task { await autonomousVM.sendChatMessage(prompt) }
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "sparkle")
                                                            .font(.system(size: 13))
                                                            .foregroundColor(CoreonColors.violet)
                                                        Text(prompt)
                                                            .font(CoreonFonts.regular(14))
                                                            .foregroundColor(CoreonColors.textPrimary)
                                                            .multilineTextAlignment(.leading)
                                                        Spacer()
                                                        Image(systemName: "arrow.right")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(CoreonColors.textMuted)
                                                    }
                                                    .padding(12)
                                                    .background(Color.white)
                                                    .cornerRadius(CoreonRadius.md)
                                                    .shadow(color: .black.opacity(0.04), radius: 4)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(CoreonSpacing.xl)
                                    .padding(.top, 40)
                                } else {
                                    ForEach(autonomousVM.chatMessages) { msg in
                                        ChatBubble(message: msg)
                                            .id(msg.id)
                                    }

                                    if autonomousVM.isChatLoading {
                                        HStack {
                                            TypingIndicator()
                                            Spacer()
                                        }
                                        .padding(.horizontal, CoreonSpacing.xl)
                                    }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                        .onChange(of: autonomousVM.chatMessages.count) { _ in
                            if let lastId = autonomousVM.chatMessages.last?.id {
                                withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                            }
                        }
                    }
                }

                // Input bar
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 10) {
                        TextField("Pergunte ao seu coach...", text: $inputText, axis: .vertical)
                            .font(CoreonFonts.regular(15))
                            .lineLimit(1...4)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(CoreonColors.background)
                            .cornerRadius(CoreonRadius.pill)
                            .overlay(
                                RoundedRectangle(cornerRadius: CoreonRadius.pill)
                                    .stroke(CoreonColors.border, lineWidth: 1)
                            )

                        Button {
                            let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !text.isEmpty else { return }
                            inputText = ""
                            Task { await autonomousVM.sendChatMessage(text) }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(inputText.isEmpty ? CoreonColors.textMuted : LinearGradient.autonomousGradient)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, CoreonSpacing.lg)
                    .padding(.vertical, CoreonSpacing.md)
                    .background(Color.white)
                }
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Coach IA")
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }

            if !isUser {
                ZStack {
                    Circle()
                        .fill(LinearGradient.autonomousGradient)
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            Text(message.content)
                .font(CoreonFonts.regular(14))
                .foregroundColor(isUser ? .white : CoreonColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isUser {
                            AnyView(LinearGradient.autonomousGradient)
                        } else {
                            AnyView(Color.white)
                        }
                    }
                )
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 4)

            if isUser { Spacer(minLength: 0).frame(width: 0) }
            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, CoreonSpacing.lg)
    }
}

struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(CoreonColors.textMuted)
                    .frame(width: 7, height: 7)
                    .scaleEffect(animating ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: animating)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(18)
        .onAppear { animating = true }
    }
}
