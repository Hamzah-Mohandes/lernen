import SwiftUI

// Enum für Tab-Identifikation
enum TabItem: String, CaseIterable {
    case chats = "Chats"
    case calls = "Anrufe"
    case status = "Status"
    case settings = "Einstellungen"
    
    var systemImage: String {
        switch self {
        case .chats: return "message.fill"
        case .calls: return "phone.fill"
        case .status: return "circle.dashed"
        case .settings: return "gear"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: TabItem = .chats
    @State private var tabCustomization = TabViewCustomization()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Chat Tab
            ChatView()
                .tag(TabItem.chats)
                .tabItem {
                    Label(TabItem.chats.rawValue,
                          systemImage: TabItem.chats.systemImage)
                }
                .badge(3) // Zeigt Benachrichtigungszähler
            
            // Anrufe Tab
            CallsView()
                .tag(TabItem.calls)
                .tabItem {
                    Label(TabItem.calls.rawValue,
                          systemImage: TabItem.calls.systemImage)
                }
            
            // Status Tab
            StatusView()
                .tag(TabItem.status)
                .tabItem {
                    Label(TabItem.status.rawValue,
                          systemImage: TabItem.status.systemImage)
                }
            
            // Einstellungen Tab
            SettingsView()
                .tag(TabItem.settings)
                .tabItem {
                    Label(TabItem.settings.rawValue,
                          systemImage: TabItem.settings.systemImage)
                }
        }
        .tabViewCustomization($tabCustomization) // Ermöglicht Tab-Anpassung
        .onChange(of: selectedTab) { newValue in
            // Reagiere auf Tab-Wechsel
            print("Tab gewechselt zu: \(newValue)")
        }
    }
}

// Beispiel-Views für die Tabs
struct ChatView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(1...10, id: \.self) { index in
                    NavigationLink(destination: Text("Chat \(index)")) {
                        HStack {
                            Circle()
                                .fill(.blue)
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text("Chat \(index)")
                                    .font(.headline)
                                Text("Letzte Nachricht...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chats")
        }
    }
}

struct CallsView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(1...5, id: \.self) { index in
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                        Text("Anruf \(index)")
                        Spacer()
                        Text("Heute")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Anrufe")
        }
    }
}

struct StatusView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(1...3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.blue.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Text("Status \(index)")
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("Status")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Profil") {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading) {
                            Text("Max Mustermann")
                                .font(.headline)
                            Text("Online")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Allgemein") {
                    Toggle("Benachrichtigungen", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(false))
                }
            }
            .navigationTitle("Einstellungen")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
