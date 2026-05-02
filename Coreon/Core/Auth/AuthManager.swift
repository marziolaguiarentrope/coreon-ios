import Foundation
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?

    private let client = Base44Client.shared

    private init() {}

    // MARK: - Check auth status on launch
    func checkAuthStatus() async {
        guard client.getToken() != nil else {
            isAuthenticated = false
            return
        }
        do {
            let user = try await client.auth.me()
            currentUser = user
            isAuthenticated = true
        } catch {
            client.setToken(nil)
            isAuthenticated = false
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let response = try await client.auth.loginWithEmail(email: email, password: password)
        client.setToken(response.token)
        currentUser = response.user
        isAuthenticated = true
    }

    // MARK: - Register
    func register(email: String, password: String, fullName: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let _ = try await client.auth.signUp(email: email, password: password, fullName: fullName)
    }

    // MARK: - Verify OTP
    func verifyOtp(email: String, code: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let response = try await client.auth.verifyOtp(email: email, code: code)
        client.setToken(response.token)
        currentUser = response.user
        isAuthenticated = true
    }

    // MARK: - Resend OTP
    func resendOtp(email: String) async throws {
        let _ = try await client.auth.resendOtp(email: email)
    }

    // MARK: - Logout
    func logout() {
        client.auth.logout()
        currentUser = nil
        isAuthenticated = false
        AppState.shared.clearMode()
    }

    // MARK: - Refresh
    func refreshUser() async {
        guard let user = try? await client.auth.me() else { return }
        currentUser = user
    }
}
