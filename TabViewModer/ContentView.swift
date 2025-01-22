import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    // MARK: - Tab Enum
    enum Tab: String, CaseIterable {
        case home = "house.fill"
        case favorites = "heart.fill"
        case settings = "gearshape.fill"

        var title: String {
            switch self {
            case .home: return "Home"
            case .favorites: return "Favorites"
            case .settings: return "Settings"
            }
        }
    }

    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.rawValue)
                }
                .tag(Tab.home)

            FavoritesView()
                .tabItem {
                    Label(Tab.favorites.title, systemImage: Tab.favorites.rawValue)
                }
                .tag(Tab.favorites)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.rawValue)
                }
                .tag(Tab.settings)
        }
        .tint(.blue) // Setzt die Akzentfarbe für die Tabs
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Aktion für den Leading Button
                }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Aktion für den Trailing Button
                }) {
                    Image(systemName: "bell")
                }
            }
        }
    }
}

// MARK: - HomeView
struct HomeView: View {
    @State private var isAnimated: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Home Screen")
                    .navigationTitle("Home")
                    .scaleEffect(isAnimated ? 1.5 : 1.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            isAnimated.toggle()
                        }
                    }
            }
        }
    }
}

// MARK: - FavoritesView
struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            Text("Favorites Screen")
                .navigationTitle("Favorites")
        }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Settings Screen")
                .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
