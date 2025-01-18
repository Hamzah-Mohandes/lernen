import SwiftUI



struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel() // Verwende das ViewModel für die Authentifizierung
    @StateObject private var userManager = UserManager() // BenutzerManager als StateObject
    @State private var showRegisterView: Bool = false // Zustand für die Anzeige der Registrierungsansicht
    @State private var selectedTab = 0 // Aktuell ausgewählte Tab

    var body: some View {
        if viewModel.isLoggedIn {
            TabView(selection: $selectedTab) {
                // Home Tab
                Tab("Home", systemImage: "house", value: 1) {
                    NavigationView {
                        HomeView()
                            .navigationTitle("Home") // Titel für die Navigation
                    }
                }

                // Profil Tab
                Tab("Profil", systemImage: "person", value: 2) {
                    NavigationView {
                        ProfileView()
                            .navigationTitle("Profil") // Titel für die Navigation
                    }
                }

                // Einstellungen Tab
                Tab("Einstellungen", systemImage: "gear", value: 3) {
                    NavigationView {
                        SettingsView()
                            .navigationTitle("Einstellungen") // Titel für die Navigation
                    }
                }
            }
            
            
        } else {
            // Login-Ansicht, wenn der Benutzer nicht eingeloggt ist
            VStack {
                LoginView(viewModel: viewModel) // Login-Ansicht
                Button("Registrieren") {
                    showRegisterView.toggle() // Registrierungsansicht anzeigen
                }
                .padding()
            }
            .fullScreenCover(isPresented: $showRegisterView) {
                RegisterView()
                    .environmentObject(userManager) // BenutzerManager übergeben
                    .environmentObject(viewModel) // AuthViewModel übergeben
            }
        }
    }
}

#Preview {
    ContentView()
}
