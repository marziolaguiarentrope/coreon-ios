import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        Task {
                            await authManager.checkAuthStatus()
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showSplash = false
                            }
                        }
                    }
            } else if !authManager.isAuthenticated {
                WelcomeView()
            } else if let mode = appState.selectedMode {
                switch mode {
                case .student:
                    StudentTabView()
                case .professional:
                    ProfessionalTabView()
                case .autonomous:
                    AutonomousTabView()
                }
            } else {
                ChooseModeView()
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
        .animation(.easeInOut, value: appState.selectedMode)
    }
}
