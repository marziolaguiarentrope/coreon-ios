import SwiftUI

struct ProfessionalTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var proVM = ProfessionalViewModel()
    @State private var showMoreSheet = false

    var body: some View {
        TabView {
            ProfessionalClientsView()
                .tabItem { Label("Clientes", systemImage: "person.2.fill") }
                .environmentObject(proVM)

            ProfessionalProgramsView()
                .tabItem { Label("Programas", systemImage: "list.bullet.clipboard.fill") }
                .environmentObject(proVM)

            ProfessionalWorkoutsView()
                .tabItem { Label("Treinos", systemImage: "dumbbell.fill") }
                .environmentObject(proVM)

            ProfessionalAnamnesisView()
                .tabItem { Label("Anamneses", systemImage: "doc.text.fill") }
                .environmentObject(proVM)

            ProfessionalMoreView()
                .tabItem { Label("Mais", systemImage: "ellipsis.circle.fill") }
                .environmentObject(proVM)
        }
        .accentColor(CoreonColors.primary)
        .onAppear {
            Task { await proVM.load(userEmail: authManager.currentUser?.email ?? "") }
        }
    }
}

// MARK: - Professional ViewModel
@MainActor
class ProfessionalViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var programs: [WorkoutProgram] = []
    @Published var workouts: [Workout] = []
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = Base44Client.shared

    func load(userEmail: String) async {
        guard !userEmail.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let clientsTask: [Client] = api.entities("Client").filter(["assigned_trainer": userEmail])
            async let nutriClientsTask: [Client] = api.entities("Client").filter(["assigned_nutri": userEmail])
            async let programsTask: [WorkoutProgram] = api.entities("WorkoutProgram").filter(["created_by": userEmail], sortBy: "-created_date")
            async let workoutsTask: [Workout] = api.entities("Workout").filter(["created_by": userEmail], sortBy: "-created_date")

            let (trainerClients, nutriClients, progs, wkts) = try await (clientsTask, nutriClientsTask, programsTask, workoutsTask)

            // Merge clients (dedup by id)
            var map: [String: Client] = [:]
            (trainerClients + nutriClients).forEach { map[$0.id] = $0 }
            clients = Array(map.values).sorted { ($0.fullName ?? "") < ($1.fullName ?? "") }
            programs = progs
            workouts = wkts
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadExercises() async {
        guard exercises.isEmpty else { return }
        exercises = (try? await api.entities("Exercise").list()) ?? []
    }
}
