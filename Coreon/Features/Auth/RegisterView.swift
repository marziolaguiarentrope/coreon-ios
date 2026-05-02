import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var step = 1
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var otpCode = ""
    @State private var errorMessage: String?
    @State private var registeredEmail = ""

    var body: some View {
        ScrollView {
            VStack(spacing: CoreonSpacing.xl) {
                // Step indicator
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i <= step ? CoreonColors.primary : CoreonColors.border)
                            .frame(height: 4)
                    }
                }
                .padding(.top, CoreonSpacing.xxl)

                // Header
                VStack(spacing: 8) {
                    Text(stepTitle)
                        .font(CoreonFonts.bold(26))
                        .foregroundColor(CoreonColors.textPrimary)
                    Text(stepSubtitle)
                        .font(CoreonFonts.regular(14))
                        .foregroundColor(CoreonColors.textMuted)
                        .multilineTextAlignment(.center)
                }

                // Form
                VStack(spacing: CoreonSpacing.md) {
                    if step == 1 {
                        CoreonLabeledField("Nome completo", required: true) {
                            CoreonTextField(placeholder: "Seu nome", text: $fullName, icon: "person")
                        }
                        CoreonLabeledField("Email", required: true) {
                            CoreonTextField(placeholder: "seu@email.com", text: $email, keyboardType: .emailAddress, icon: "envelope")
                        }
                    } else if step == 2 {
                        CoreonLabeledField("Senha", required: true) {
                            CoreonTextField(placeholder: "Mínimo 6 caracteres", text: $password, isSecure: true, icon: "lock")
                        }
                        CoreonLabeledField("Confirmar senha", required: true) {
                            CoreonTextField(placeholder: "Repita a senha", text: $confirmPassword, isSecure: true, icon: "lock.rotation")
                        }
                    } else {
                        VStack(spacing: CoreonSpacing.md) {
                            Image(systemName: "envelope.badge")
                                .font(.system(size: 48))
                                .foregroundColor(CoreonColors.primary)
                            Text("Enviamos um código para\n\(registeredEmail)")
                                .font(CoreonFonts.regular(14))
                                .foregroundColor(CoreonColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        CoreonLabeledField("Código de verificação", required: true) {
                            CoreonTextField(placeholder: "000000", text: $otpCode, keyboardType: .numberPad, icon: "key")
                        }
                        Button("Reenviar código") {
                            Task { try? await authManager.resendOtp(email: registeredEmail) }
                        }
                        .font(CoreonFonts.medium(13))
                        .foregroundColor(CoreonColors.primary)
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .font(CoreonFonts.regular(13))
                        .foregroundColor(CoreonColors.danger)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CoreonColors.danger.opacity(0.08))
                        .cornerRadius(CoreonRadius.md)
                }

                CoreonButton(buttonTitle, isLoading: authManager.isLoading) {
                    Task { await handleNext() }
                }

                if step > 1 && step < 3 {
                    Button("Voltar") { step -= 1 }
                        .font(CoreonFonts.medium(14))
                        .foregroundColor(CoreonColors.textMuted)
                }
            }
            .padding(.horizontal, CoreonSpacing.xl)
            .padding(.bottom, 40)
        }
        .background(CoreonColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var stepTitle: String {
        switch step {
        case 1: return "Criar conta"
        case 2: return "Sua senha"
        default: return "Verificar email"
        }
    }

    private var stepSubtitle: String {
        switch step {
        case 1: return "Insira seus dados pessoais"
        case 2: return "Crie uma senha segura"
        default: return "Digite o código recebido"
        }
    }

    private var buttonTitle: String {
        switch step {
        case 1: return "Continuar"
        case 2: return "Criar conta"
        default: return "Verificar"
        }
    }

    private func handleNext() async {
        errorMessage = nil
        switch step {
        case 1:
            guard !fullName.isEmpty, !email.isEmpty else {
                errorMessage = "Preencha todos os campos"
                return
            }
            step = 2
        case 2:
            guard !password.isEmpty else { errorMessage = "Digite uma senha"; return }
            guard password.count >= 6 else { errorMessage = "Senha deve ter pelo menos 6 caracteres"; return }
            guard password == confirmPassword else { errorMessage = "Senhas não coincidem"; return }
            do {
                try await authManager.register(email: email, password: password, fullName: fullName)
                registeredEmail = email
                step = 3
            } catch {
                errorMessage = error.localizedDescription
            }
        case 3:
            guard !otpCode.isEmpty else { errorMessage = "Digite o código"; return }
            do {
                try await authManager.verifyOtp(email: registeredEmail, code: otpCode)
            } catch {
                errorMessage = error.localizedDescription
            }
        default: break
        }
    }
}
