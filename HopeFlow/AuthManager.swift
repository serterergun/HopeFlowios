import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private(set) var isAuthenticated = false
    private(set) var currentUser: User? = nil
    private(set) var token: String? = nil
    
    private init() {
        // Ensure user is logged out by default
        isAuthenticated = false
        currentUser = nil
        token = nil
        checkAuthStatus()
    }
    
    func login(email: String, password: String) async throws {
        do {
            // 1. Login endpoint (should return token)
            let (_, token) = try await NetworkManager.shared.loginAndGetToken(email: email, password: password)
            self.token = token
            UserDefaults.standard.set(token, forKey: "authToken")
            // 2. Fetch current user with token
            let user = try await NetworkManager.shared.getCurrentUser(token: token)
            self.currentUser = user
            self.isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
        } catch {
            throw error
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        do {
            let user = try await NetworkManager.shared.register(firstName: firstName, lastName: lastName, email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
        } catch {
            throw error
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        token = nil
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "authToken")
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
        // Clear any stored auth tokens
    }
    
    private func checkAuthStatus() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        token = UserDefaults.standard.string(forKey: "authToken")
        // If authenticated, fetch user data from API
        if isAuthenticated, let token = token {
            Task {
                do {
                    let user = try await NetworkManager.shared.getCurrentUser(token: token)
                    self.currentUser = user
                } catch {
                    self.logout()
                }
            }
        }
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil && token != nil
    }
}

// Notification.Name extension
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
} 