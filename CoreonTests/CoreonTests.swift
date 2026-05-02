import XCTest
@testable import Coreon

final class CoreonTests: XCTestCase {
    func testAuthManagerInitialState() {
        let auth = AuthManager.shared
        // Initial state: not authenticated
        XCTAssertFalse(auth.isAuthenticated)
        XCTAssertNil(auth.currentUser)
    }

    func testAppModeStorage() {
        let state = AppState.shared
        state.selectedMode = .professional
        XCTAssertEqual(state.selectedMode, .professional)
        state.clearMode()
        XCTAssertNil(state.selectedMode)
    }

    func testKeychainStorage() {
        let keychain = KeychainStorage.shared
        keychain.set(key: "test_key", value: "test_value")
        XCTAssertEqual(keychain.get(key: "test_key"), "test_value")
        keychain.delete(key: "test_key")
        XCTAssertNil(keychain.get(key: "test_key"))
    }
}
