import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isAnimating: Bool = false
    @State private var buttonColor: Color = .blue
    @State private var buttonScale: CGFloat = 1.0
    @State private var backgroundColor: Color = .white

    var body: some View {
        ZStack {
            // Hintergrundanimation
            Rectangle()
                .fill(backgroundColor)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: backgroundColor)
                .onAppear {
                    backgroundColor = .yellow // Hintergrundfarbe ändern
                }

            VStack {
                Text("Anmelden")
                    .font(.largeTitle)
                    .padding()

                // Textfeld für den Benutzernamen
                TextField("Benutzername", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.8)) // Textfeld-Hintergrundfarbe
                    .scaleEffect(isAnimating ? 1.05 : 1.0) // Subtile Animation
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)

                // Textfeld für das Passwort
                SecureField("Passwort", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.8)) // Textfeld-Hintergrundfarbe
                    .scaleEffect(isAnimating ? 1.05 : 1.0) // Subtile Animation
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)

                // Einloggen-Button
                Button(action: {
                    viewModel.login(username: username, password: password)
                    buttonColor = buttonColor == .blue ? .green : .blue // Farbwechsel
                    buttonScale = buttonScale == 1.0 ? 1.1 : 1.0 // Skalierung
                }) {
                    Text("Einloggen")
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .scaleEffect(buttonScale)
                        .animation(.easeInOut(duration: 0.3), value: buttonScale)
                }
                .padding()
            }
            .onAppear {
                isAnimating = true // Animation starten
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}