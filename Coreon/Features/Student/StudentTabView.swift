import SwiftUI

struct StudentTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var studentVM = StudentViewModel()

    var body: some View {
        TabView {
            StudentHomeView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }
                .environmentObject(studentVM)

            StudentWorkoutsView()
                .tabItem {
                    Label("Treinos", systemImage: "dumbbell.fill")
                }
                .environmentObject(studentVM)

            StudentProgressView()
                .tabItem {
                    Label("Progresso", systemImage: "chart.line.uptrend.xyaxis")
                }
                .environmentObject(studentVM)

            StudentMessagesView()
                .tabItem {
                    Label("Mensagens", systemImage: "message.fill")
                }
                .environmentObject(studentVM)

            StudentProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
                .environmentObject(studentVM)
        }
        .accentColor(CoreonColors.cyan)
        .onAppear {
            Task { await studentVM.load(userEmail: authManager.currentUser?.email ?? "") }
        }
    }
}

// MARK: - Student ViewModel
@MainActor
class StudentViewModel: ObservableObject {
    @Published var client: Client?
    @Published var workouts: [Workout] = []
    @Published var checkins: [DailyCheckin] = []
    @Published var appointments: [Appointment] = []
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = Base44Client.shared

    func load(userEmail: String) async {
        guard !userEmail.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let workoutsTask = api.entities("Workout").filter(["client_email": userEmail], sortBy: "-workout_date")
            async let checkinsTask = api.entities("DailyCheckin").filter(["client_email": userEmail], sortBy: "-checkin_date")
            async let appointmentsTask = api.entities("Appointment").filter(["client_email": userEmail])
            async let messagesTask = api.entities("Message").filter(["to_email": userEmail])
            let (w, c, a, m) = try await (workoutsTask as [Workout], checkinsTask as [DailyCheckin], appointmentsTask as [Appointment], messagesTask as [Message])
            workouts = w
            checkins = c
            appointments = a
            messages = m
        } catch {
            self.error = error.localizedDescription
        }
    }
}
