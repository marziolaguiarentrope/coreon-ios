import SwiftUI

struct AutonomousOnboardingView: View {
    @EnvironmentObject var autonomousVM: AutonomousViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var step = 0
    @State private var goal = ""
    @State private var fitnessLevel = ""
    @State private var daysPerWeek = 3
    @State private var restrictions = ""
    @State private var isGenerating = false

    let goals = ["Perda de peso", "Ganho muscular", "Resistência", "Saúde geral", "Performance atlética", "Flexibilidade"]
    let levels = ["Iniciante", "Intermediário", "Avançado"]

    var body: some View {
        ZStack {
            LinearGradient.autonomousGradient.ignoresSafeArea()

            if isGenerating {
                generatingView
            } else {
                VStack(spacing: 0) {
                    // Progress
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { i in
                            Capsule()
                                .fill(i <= step ? Color.white : Color.white.opacity(0.3))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, 60)

                    Spacer()

                    // Step content
                    VStack(spacing: CoreonSpacing.xl) {
                        switch step {
                        case 0: goalStep
                        case 1: levelStep
                        case 2: daysStep
                        case 3: restrictionsStep
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    Spacer()

                    // Navigation
                    VStack(spacing: 12) {
                        Button(step < 3 ? "Continuar" : "Gerar meu plano com IA") {
                            if step < 3 {
                                step += 1
                            } else {
                                Task { await finish() }
                            }
                        }
                        .font(CoreonFonts.semibold(16))
                        .foregroundColor(CoreonColors.violet)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .cornerRadius(CoreonRadius.lg)
                        .disabled(stepIsInvalid)

                        if step > 0 {
                            Button("Voltar") { step -= 1 }
                                .font(CoreonFonts.medium(14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var stepIsInvalid: Bool {
        switch step {
        case 0: return goal.isEmpty
        case 1: return fitnessLevel.isEmpty
        default: return false
        }
    }

    private var goalStep: some View {
        VStack(spacing: CoreonSpacing.xl) {
            VStack(spacing: 8) {
                Text("Qual é seu objetivo?")
                    .font(CoreonFonts.bold(28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Nossa IA vai criar um plano personalizado para você.")
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(goals, id: \.self) { g in
                    Button(g) { goal = g }
                        .font(CoreonFonts.medium(14))
                        .foregroundColor(goal == g ? CoreonColors.violet : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(goal == g ? Color.white : Color.white.opacity(0.15))
                        .cornerRadius(CoreonRadius.lg)
                }
            }
        }
    }

    private var levelStep: some View {
        VStack(spacing: CoreonSpacing.xl) {
            VStack(spacing: 8) {
                Text("Qual seu nível atual?")
                    .font(CoreonFonts.bold(28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Isso ajuda a calibrar a intensidade do seu plano.")
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                ForEach(levels, id: \.self) { l in
                    Button(l) { fitnessLevel = l }
                        .font(CoreonFonts.semibold(16))
                        .foregroundColor(fitnessLevel == l ? CoreonColors.violet : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(fitnessLevel == l ? Color.white : Color.white.opacity(0.15))
                        .cornerRadius(CoreonRadius.lg)
                }
            }
        }
    }

    private var daysStep: some View {
        VStack(spacing: CoreonSpacing.xl) {
            VStack(spacing: 8) {
                Text("Quantos dias por semana?")
                    .font(CoreonFonts.bold(28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Seja realista — consistência é mais importante que frequência.")
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                ForEach([2, 3, 4, 5, 6], id: \.self) { d in
                    Button("\(d)") { daysPerWeek = d }
                        .font(CoreonFonts.bold(22))
                        .foregroundColor(daysPerWeek == d ? CoreonColors.violet : .white)
                        .frame(width: 52, height: 52)
                        .background(daysPerWeek == d ? Color.white : Color.white.opacity(0.15))
                        .cornerRadius(CoreonRadius.pill)
                }
            }

            Text("Dias por semana selecionados: \(daysPerWeek)")
                .font(CoreonFonts.medium(15))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private var restrictionsStep: some View {
        VStack(spacing: CoreonSpacing.xl) {
            VStack(spacing: 8) {
                Text("Alguma restrição?")
                    .font(CoreonFonts.bold(28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Lesões, limitações físicas ou preferências que a IA deve considerar.")
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            TextEditor(text: $restrictions)
                .font(CoreonFonts.regular(15))
                .padding(12)
                .frame(minHeight: 120)
                .background(Color.white.opacity(0.15))
                .cornerRadius(CoreonRadius.lg)
                .foregroundColor(.white)

            Text("Ou deixe em branco se não houver.")
                .font(CoreonFonts.regular(13))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private var generatingView: some View {
        VStack(spacing: CoreonSpacing.xl) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.8)

            VStack(spacing: 8) {
                Text("Gerando seu plano...")
                    .font(CoreonFonts.bold(24))
                    .foregroundColor(.white)
                Text("Nossa IA está criando um programa personalizado para você com base no seu perfil.")
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, CoreonSpacing.xl)
    }

    private func finish() async {
        isGenerating = true
        let profile = AutonomousProfile(
            userId: authManager.currentUser?.id,
            name: authManager.currentUser?.fullName,
            goal: goal,
            fitnessLevel: fitnessLevel,
            daysPerWeek: daysPerWeek,
            restrictions: restrictions.isEmpty ? nil : restrictions,
            xp: 0, streak: 0, completedWorkouts: 0,
            createdAt: Date()
        )
        await autonomousVM.completeOnboarding(profile: profile)
        isGenerating = false
    }
}
