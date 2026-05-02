import Foundation

enum AppMode: String, Codable {
    case student
    case professional
    case autonomous
}

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var selectedMode: AppMode? {
        didSet {
            if let mode = selectedMode {
                UserDefaults.standard.set(mode.rawValue, forKey: "COREON_MODE")
            } else {
                UserDefaults.standard.removeObject(forKey: "COREON_MODE")
            }
        }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: "COREON_MODE"),
           let mode = AppMode(rawValue: raw) {
            self.selectedMode = mode
        }
    }

    func clearMode() {
        selectedMode = nil
    }
}
