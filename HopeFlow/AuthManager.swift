import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    var currentUser: User? = nil
    private(set) var token: String? = nil
    
    var isLoggedIn: Bool {
        return currentUser != nil && token != nil && !token!.isEmpty
    }
    
    // Deprecated - maintained for backward compatibility
    var isAuthenticated: Bool {
        return isLoggedIn
    }
    
    private init() {
        checkAuthStatus()
    }
    
    func login(email: String, password: String) async throws {
        do {
            print("DEBUG: Starting login process for email: \(email)")
            // Use the login method that returns both user and token
            let (user, token) = try await NetworkManager.shared.login(email: email, password: password)
            print("DEBUG: Login successful, token received")
            self.currentUser = user
            self.token = token
            // Persist auth state
            UserDefaults.standard.set(token, forKey: "authToken")
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            print("DEBUG: Auth state updated")
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            print("DEBUG: Login process completed successfully")
        } catch {
            print("DEBUG: Login failed with error: \(error)")
            logout()
            throw error
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        do {
            let user = try await NetworkManager.shared.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            
            // Registration doesn't automatically login
            self.currentUser = nil
            self.token = nil
            
            // Clear any previous auth state
            UserDefaults.standard.set(false, forKey: "isAuthenticated")
            UserDefaults.standard.removeObject(forKey: "authToken")
            // userId'yi kaydet
            if let userId = user.id {
                UserDefaults.standard.set(userId, forKey: "userId")
            }
            
            NotificationCenter.default.post(name: .userDidRegister, object: nil)
        } catch {
            throw error
        }
    }
    
    func logout() {
        currentUser = nil
        token = nil
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "authToken")
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    private func checkAuthStatus() {
        guard let savedToken = UserDefaults.standard.string(forKey: "authToken"),
              !savedToken.isEmpty,
              UserDefaults.standard.bool(forKey: "isAuthenticated") else {
            logout()
            return
        }
        self.token = savedToken
        Task {
            do {
                let user = try await NetworkManager.shared.getCurrentUser(token: savedToken)
                await MainActor.run {
                    self.currentUser = user
                    print("DEBUG: Auto-login successful for \(user.email ?? "nil")")
                }
            } catch {
                print("DEBUG: Token validation failed: \(error)")
                await MainActor.run {
                    self.logout()
                }
            }
        }
    }
    
    func validateToken() async -> Bool {
        guard let token = token, !token.isEmpty else {
            logout()
            return false
        }
        do {
            let user = try await NetworkManager.shared.getCurrentUser(token: token)
            await MainActor.run {
                self.currentUser = user
            }
            return true
        } catch {
            logout()
            return false
        }
    }
}

// Notification.Name extension
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let userDidRegister = Notification.Name("userDidRegister")
}