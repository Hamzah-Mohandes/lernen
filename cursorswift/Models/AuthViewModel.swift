import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    private var userManager = UserManager() // Instanz des UserManagers
    
    func login(username: String, password: String) {
        isLoggedIn = userManager.login(username: username, password: password)
    }
    
    func logout() {
        userManager.logout()
        isLoggedIn = false
    }
} 