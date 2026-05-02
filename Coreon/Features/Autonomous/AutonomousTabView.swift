import SwiftUI

struct AutonomousTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var autonomousVM = AutonomousViewModel()

    var body: some View {
        Group {
            if autonomousVM.needsOnboarding {
                AutonomousOnboardingView()
                    .environmentObject(autonomousVM)
            } else {
                TabView {
                    AutonomousHomeView()
                        .tabItem { Label("Início", systemImage: "house.fill") }
                        .environmentObject(autonomousVM)

                    AutonomousCoachView()
                        .tabItem { Label("Coach", systemImage: "sparkles") }
                        .environmentObject(autonomousVM)

                    AutonomousWorkoutView()
                        .tabItem { Label("Treino", systemImage: "dumbbell.fill") }
                        .environmentObject(autonomousVM)

                    AutonomousNutritionView()
                        .tabItem { Label("Nutrição", systemImage: "fork.knife") }
                        .environmentObject(autonomousVM)

                    AutonomousProgressView()
                        .tabItem { Label("Progresso", systemImage: "chart.line.uptrend.xyaxis") }
                        .environmentObject(autonomousVM)

                    AutonomousProfileView()
                        .tabItem { Label("Perfil", systemImage: "person.fill") }
                        .environmentObject(autonomousVM)
                }
                .accentColor(CoreonColors.violet)
            }
        }
        .onAppear {
            Task { await autonomousVM.load(user: authManager.currentUser) }
        }
    }
}

// MARK: - Autonomous ViewModel
@MainActor
class AutonomousViewModel: ObservableObject {
    @Published var profile: AutonomousProfile?
    @Published var workoutPlan: [WorkoutDay] = []
    @Published var mealLog: [MealRecord] = []
    @Published var checkins: [DailyCheckin] = []
    @Published var completedWorkouts: Int = 0
    @Published var streak: Int = 0
    @Published var xp: Int = 0
    @Published var needsOnboarding = true
    @Published var isGeneratingPlan = false
    @Published var isLoading = false
    @Published var chatMessages: [ChatMessage] = []
    @Published var isChatLoading = false

    private let storageKey = "@coreon_autonomous_profile"

    func load(user: User?) async {
        guard let user = user else { return }
        isLoading = true
        defer { isLoading = false }

        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: storageKey + user.id),
           let profile = try? JSONDecoder().decode(AutonomousProfile.self, from: data) {
            self.profile = profile
            self.needsOnboarding = false
            self.xp = profile.xp ?? 0
            self.streak = profile.streak ?? 0
            self.completedWorkouts = profile.completedWorkouts ?? 0
        }

        // Load checkins
        if let email = user.email {
            checkins = (try? await Base44Client.shared.entities("DailyCheckin").filter(["client_email": email], sortBy: "-checkin_date")) ?? []
        }
    }

    func completeOnboarding(profile: AutonomousProfile) async {
        self.profile = profile
        self.needsOnboarding = false
        saveProfile(profile)
        isGeneratingPlan = true
        await generatePlan(profile: profile)
        isGeneratingPlan = false
    }

    private func generatePlan(profile: AutonomousProfile) async {
        let prompt = """
        Crie um plano de treino e nutrição personalizado para:
        Nome: \(profile.name ?? "Usuário")
        Objetivo: \(profile.goal ?? "saúde geral")
        Nível: \(profile.fitnessLevel ?? "iniciante")
        Dias por semana: \(profile.daysPerWeek ?? 3)
        Restrições: \(profile.restrictions ?? "nenhuma")

        Responda em formato JSON com: workoutPlan (array de 7 dias com exercícios) e dailyCalories.
        """
        guard let response = try? await Base44Client.shared.integrations.invokeLLM(prompt: prompt) else { return }
        // Parse and store plan
        if let data = response.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Store plan details
        }
    }

    func sendChatMessage(_ text: String) async {
        let userMsg = ChatMessage(id: UUID().uuidString, role: "user", content: text)
        chatMessages.append(userMsg)
        isChatLoading = true
        defer { isChatLoading = false }

        let context = buildContext()
        let prompt = """
        Você é o Coach IA do Coreon. Contexto do usuário:
        \(context)

        Pergunta: \(text)

        Responda de forma prática, motivadora e personalizada.
        """

        if let response = try? await Base44Client.shared.integrations.invokeLLM(prompt: prompt) {
            let botMsg = ChatMessage(id: UUID().uuidString, role: "assistant", content: response)
            chatMessages.append(botMsg)
        }
    }

    private func buildContext() -> String {
        var lines: [String] = []
        if let p = profile {
            lines.append("Objetivo: \(p.goal ?? "N/A")")
            lines.append("Nível: \(p.fitnessLevel ?? "N/A")")
            lines.append("Treinos concluídos: \(completedWorkouts)")
            lines.append("Streak: \(streak) dias")
        }
        if !checkins.isEmpty {
            lines.append("Últimos check-ins: \(checkins.prefix(5).map { "energia \($0.energyLevel ?? 0)/10" }.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }

    func logMeal(_ meal: MealRecord) {
        mealLog.insert(meal, at: 0)
    }

    private func saveProfile(_ profile: AutonomousProfile) {
        guard let userId = profile.userId,
              let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: storageKey + userId)
    }
}

// MARK: - Models
struct AutonomousProfile: Codable {
    var userId: String?
    var name: String?
    var goal: String?
    var fitnessLevel: String?
    var daysPerWeek: Int?
    var restrictions: String?
    var xp: Int?
    var streak: Int?
    var completedWorkouts: Int?
    var createdAt: Date?
}

struct WorkoutDay: Codable, Identifiable {
    let id: String
    var dayName: String
    var exercises: [WorkoutExerciseEntry]
    var completed: Bool
}

struct MealRecord: Codable, Identifiable {
    let id: String
    var name: String
    var calories: Int?
    var protein: Double?
    var carbs: Double?
    var fat: Double?
    var loggedAt: Date
    var imageUrl: String?
    var source: String? // manual, ai_photo
}

struct ChatMessage: Identifiable {
    let id: String
    let role: String // user, assistant
    let content: String
}
