import Foundation

struct User {
    var username: String
    var password: String
}

class UserManager: ObservableObject {
    @Published var currentUser: User? // User wird als optional definiert ob der User eingeloggt ist oder nicht
    private var users: [User] = [] // Array zur Speicherung der registrierten Benutzer

    func login(username: String, password: String) -> Bool {
        // Hier kannst du die Logik für die Anmeldung hinzufügen
        if let user = users.first(where: { $0.username == username && $0.password == password }) {
            currentUser = user
            return true
        }
        return false
    }

    func register(username: String, password: String) -> Bool {
        // Überprüfen, ob der Benutzer bereits existiert
        if users.contains(where: { $0.username == username }) {
            print("Benutzername bereits vergeben.")
            return false
        }
        // Neuen Benutzer hinzufügen
        let newUser = User(username: username, password: password)
        users.append(newUser)
        return true
    }

    func logout() {
        currentUser = nil // currentUser wird auf nil gesetzt wenn der User ausgeloggt wird
    }
} 