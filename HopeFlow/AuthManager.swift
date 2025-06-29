import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    var currentUser: User? = nil
    private(set) var token: String? = nil
    
    // Computed property - tutarlılık için sadece bu kullanılacak
    var isLoggedIn: Bool {
        return currentUser != nil && token != nil && !token!.isEmpty
    }
    
    // Deprecated - geriye uyumluluk için tutuldu
    var isAuthenticated: Bool {
        return isLoggedIn
    }
    
    private init() {
        checkAuthStatus()
    }
    
    func login(email: String, password: String) async throws {
        do {
            print("DEBUG: Starting login process for email: \(email)")
            
            // 1. Login endpoint (should return token)
            let (_, token) = try await NetworkManager.shared.loginAndGetToken(email: email, password: password)
            print("DEBUG: Token received from login: \(token)")
            
            self.token = token
            UserDefaults.standard.set(token, forKey: "authToken")
            print("DEBUG: Token stored in AuthManager and UserDefaults")
            
            // 2. Fetch current user with token
            let user = try await NetworkManager.shared.getCurrentUser(token: token)
            self.currentUser = user
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            print("DEBUG: User fetched and stored: \(user)")
            
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            print("DEBUG: Login process completed successfully")
        } catch {
            print("DEBUG: Login failed with error: \(error)")
            // Login başarısız olursa state'i temizle
            logout()
            throw error
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        do {
            let user = try await NetworkManager.shared.register(firstName: firstName, lastName: lastName, email: email, password: password)
            self.currentUser = user
            // Register sonrası otomatik login yapılmıyor, kullanıcı manuel login yapmalı
            UserDefaults.standard.set(false, forKey: "isAuthenticated")
            UserDefaults.standard.removeObject(forKey: "authToken")
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
        let savedToken = UserDefaults.standard.string(forKey: "authToken")
        let wasAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        // Token varsa ve geçerliyse kullanıcı bilgilerini al
        if let token = savedToken, !token.isEmpty, wasAuthenticated {
            self.token = token
            Task {
                do {
                    let user = try await NetworkManager.shared.getCurrentUser(token: token)
                    self.currentUser = user
                } catch {
                    // Token geçersizse logout yap
                    self.logout()
                }
            }
        } else {
            // Token yoksa veya geçersizse logout yap
            logout()
        }
    }
    
    // Token validation
    func validateToken() async -> Bool {
        guard let token = token, !token.isEmpty else {
            logout()
            return false
        }
        
        do {
            let user = try await NetworkManager.shared.getCurrentUser(token: token)
            self.currentUser = user
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