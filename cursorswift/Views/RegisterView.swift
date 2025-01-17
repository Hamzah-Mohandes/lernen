import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAnimating: Bool = false
    @State private var registrationSuccess: Bool = false
    @EnvironmentObject var userManager: UserManager // BenutzerManager als Umgebungsobjekt
    @EnvironmentObject var viewModel: AuthViewModel // AuthViewModel als Umgebungsobjekt

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Hintergrundfarbe

            VStack {
                Text("Registrieren")
                    .font(.largeTitle)
                    .padding()

                TextField("Benutzername", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("E-Mail", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Passwort", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Passwort bestätigen", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    registerUser()
                }) {
                    Text("Registrieren")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onAppear {
                isAnimating = true // Animation starten, falls gewünscht
            }
        }
    }

    private func registerUser() {
        // Hier kannst du die Logik für die Registrierung hinzufügen
        if password == confirmPassword {
            if userManager.register(username: username, password: password) {
                registrationSuccess = true
                print("Benutzer registriert: \(username), E-Mail: \(email)")
                viewModel.isLoggedIn = true // Status der Anmeldung aktualisieren
            } else {
                print("Benutzername bereits vergeben.")
            }
        } else {
            print("Passwörter stimmen nicht überein.")
        }
    }
}

#Preview {
    RegisterView().environmentObject(UserManager()).environmentObject(AuthViewModel()) // Umgebungsobjekte hinzufügen
} 