import SwiftUI

// Enum zur besseren Verwaltung der Tabs
enum Tab: Int {
    case medikamente, kalender, einstellungen
}

struct ContentView: View {
    @State private var selectedTab: Tab = .medikamente

    var body: some View {
        ZStack {
            // Moderner blauer Hintergrundverlauf
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Aktueller Tab-Inhalt
            Group {
                switch selectedTab {
                case .medikamente:
                    MedicationListView()
                case .kalender:
                    CalendarView()
                case .einstellungen:
                    SettingsView()
                }
            }
            .transition(.move(edge: .leading))
            .animation(.easeInOut, value: selectedTab)
            
            // Eigene schwebende Tab-Leiste
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            TabBarButton(tab: .medikamente, selectedTab: $selectedTab, icon: "pills.fill", title: "Medikamente")
            Spacer()
            TabBarButton(tab: .kalender, selectedTab: $selectedTab, icon: "calendar", title: "Kalender")
            Spacer()
            TabBarButton(tab: .einstellungen, selectedTab: $selectedTab, icon: "gearshape.fill", title: "Einstellungen")
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct TabBarButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let icon: String
    let title: String

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = tab
                // Haptic Feedback als zusätzliches Feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }) {
            VStack(spacing: 4) {
                if selectedTab == tab {
                    // Hervorgehobener Button mit Kreiseffekt
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 50, height: 50)
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Normaler Zustand
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.7))
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(selectedTab == tab ? 1.0 : 0.7))
            }
        }
    }
}

// Dummy Views für die einzelnen Tabs (Beispielinhalte)

struct MedicationListView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Medikamentenübersicht")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            // Beispielhafter Inhalt
            Text("Hier findest Du alle Deine Medikamente.")
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 5)
            Spacer()
        }
        .padding()
    }
}

struct CalendarView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Kalender")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            // Beispielhafter Inhalt
            Text("Hier siehst Du Deine Termine und Erinnerungen.")
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 5)
            Spacer()
        }
        .padding()
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Einstellungen")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            // Beispielhafter Inhalt
            Text("Passe hier Deine App-Einstellungen an.")
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 5)
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Vorschau im dunklen Modus für den blauen Look
    }
}
