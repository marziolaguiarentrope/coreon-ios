import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showForgotPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: CoreonSpacing.xl) {
                // Header
                VStack(spacing: 8) {
                    Text("Entrar")
                        .font(CoreonFonts.bold(28))
                        .foregroundColor(CoreonColors.textPrimary)
                    Text("Acesse sua conta Coreon")
                        .font(CoreonFonts.regular(15))
                        .foregroundColor(CoreonColors.textMuted)
                }
                .padding(.top, CoreonSpacing.xxl)

                // Form
                VStack(spacing: CoreonSpacing.md) {
                    CoreonLabeledField("Email", required: true) {
                        CoreonTextField(
                            placeholder: "seu@email.com",
                            text: $email,
                            keyboardType: .emailAddress,
                            icon: "envelope"
                        )
                    }

                    CoreonLabeledField("Senha", required: true) {
                        CoreonTextField(
                            placeholder: "Sua senha",
                            text: $password,
                            isSecure: true,
                            icon: "lock"
                        )
                    }
                }

                if let error = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                        Text(error)
                            .font(CoreonFonts.regular(13))
                    }
                    .foregroundColor(CoreonColors.danger)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CoreonColors.danger.opacity(0.08))
                    .cornerRadius(CoreonRadius.md)
                }

                CoreonButton("Entrar", isLoading: authManager.isLoading) {
                    Task { await login() }
                }

                Button("Esqueci minha senha") {
                    showForgotPassword = true
                }
                .font(CoreonFonts.medium(14))
                .foregroundColor(CoreonColors.primary)

                Divider()

                NavigationLink(destination: RegisterView()) {
                    HStack(spacing: 4) {
                        Text("Não tem conta?")
                            .foregroundColor(CoreonColors.textMuted)
                        Text("Criar conta")
                            .foregroundColor(CoreonColors.primary)
                            .fontWeight(.semibold)
                    }
                    .font(CoreonFonts.regular(14))
                }
            }
            .padding(.horizontal, CoreonSpacing.xl)
            .padding(.bottom, 40)
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }

    private func login() async {
        errorMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha email e senha"
            return
        }
        do {
            try await authManager.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
