import SwiftUI

enum Tab {
    case home
    case profile
}

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel() // Verwende das ViewModel für die Authentifizierung
    @StateObject private var userManager = UserManager() // BenutzerManager als StateObject
    @State private var showRegisterView: Bool = false // Zustand für die Anzeige der Registrierungsansicht
    @State private var selectedTab: Tab = .home // Aktuell ausgewählte Tab

    var body: some View {
        if viewModel.isLoggedIn {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
                .tag(Tab.profile)
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