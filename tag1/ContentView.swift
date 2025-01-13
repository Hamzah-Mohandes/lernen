import SwiftUI
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

class OrderManager: ObservableObject {
    @Published var orderedTables: [Int] = [] // Liste der bestellten Tische
    @Published var completedOrders: [Int] = [] // Liste der abgeschlossenen Bestellungen
}

struct ContentView: View {
    @StateObject var orderManager = OrderManager() // Instanz des OrderManagers

    var body: some View {
        MainTabView()
            .environmentObject(orderManager) // Übergibt den OrderManager an die Views
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            KitchenView()
                .tabItem {
                    Label("Küche", systemImage: "fork.knife")
                }
                .tag(1)
            
            WaiterView()
                .tabItem {
                    Label("Kellner", systemImage: "person.3.fill")
                }
                .tag(2)
        }
        .accentColor(.red) // Setze die Akzentfarbe auf Rot
    }
}

struct HomeView: View {
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(orderManager.completedOrders, id: \.self) { table in
                        Text("Bestellung von Tisch \(table) ist fertig!")
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .navigationTitle("Fertige Bestellungen")
            }
        }
    }
}

struct KitchenView: View {
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    var body: some View {
        VStack {
            Text("Küchenansicht")
                .font(.largeTitle)
                .padding()
                .background(Color.red.opacity(0.5)) // Rote Hintergrundfarbe mit Opazität
                .cornerRadius(10)
                .shadow(radius: 5)

            if orderManager.orderedTables.isEmpty {
                Text("Keine Bestellungen.")
                    .foregroundColor(.red)
                    .padding()
                    .transition(.slide) // Füge eine Übergangsanimation hinzu
            } else {
                List(orderManager.orderedTables, id: \.self) { table in
                    HStack {
                        Text("Bestellung von Tisch \(table) erhalten!")
                            .padding()
                            .background(Color.red.opacity(0.2)) // Rote Hintergrundfarbe mit Opazität
                            .cornerRadius(8)

                        Button(action: {
                            markOrderAsCompleted(table: table)
                        }) {
                            Text("Fertig")
                                .padding(8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func markOrderAsCompleted(table: Int) {
        orderManager.completedOrders.append(table)
        if let index = orderManager.orderedTables.firstIndex(of: table) {
            orderManager.orderedTables.remove(at: index)
        }
    }
}

struct WaiterView: View {
    let tables = Array(1...30)
    @State private var quantities: [Int] = Array(repeating: 0, count: 80)
    @State private var selectedItem: (String, Int)?
    @State private var showingSheet = false

    var body: some View {
        NavigationView {
            List(tables, id: \.self) { table in
                NavigationLink(destination: TableDetailView(table: table, quantities: $quantities, showingSheet: $showingSheet, selectedItem: $selectedItem)) {
                    Text("Tisch \(table)")
                        .padding()
                        .background(Color.red.opacity(0.1)) // Rote Hintergrundfarbe mit Opazität
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
            .navigationTitle("Tische")
        }
    }
}

struct TableDetailView: View {
    let table: Int
    @Binding var quantities: [Int]
    @Binding var showingSheet: Bool
    @Binding var selectedItem: (String, Int)?
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    let drinks = (1...20).map { "Getränk \($0) - \(Double($0) * 1.5) €" }

    var body: some View {
        List {
            Section(header: Text("Getränke")) {
                ForEach(drinks.indices, id: \.self) { index in
                    createButton(for: drinks[index], at: index)
                }
            }
        }
        .navigationTitle("Tisch \(table)")
        .sheet(isPresented: Binding(
            get: { showingSheet && selectedItem != nil },
            set: { showingSheet = $0 }
        )) {
            if let selectedItem = selectedItem {
                QuantitySelectionView(item: selectedItem.0, quantity: $quantities[selectedItem.1])
                    .onDisappear {
                        // Füge die Tischnummer zur Liste der bestellten Tische hinzu
                        orderManager.orderedTables.append(table)
                    }
            }
        }
    }

    private func createButton(for item: String, at index: Int) -> some View {
        Button(action: {
            selectedItem = (item, index)
            showingSheet = true
        }) {
            HStack {
                Text(item)
                Spacer()
                Text("\(quantities[index])")
            }
            .padding()
            .background(Color.red.opacity(0.1)) // Rote Hintergrundfarbe mit Opazität
            .cornerRadius(8)
        }
    }
}

struct QuantitySelectionView: View {
    let item: String
    @Binding var quantity: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text(item)
                .font(.largeTitle)
                .padding()

            HStack {
                Button(action: {
                    if quantity > 0 {
                        quantity -= 1
                    }
                }) {
                    Text("-")
                        .frame(width: 50, height: 50)
                        .background(Color.red.opacity(0.2)) // Rote Hintergrundfarbe mit Opazität
                        .cornerRadius(10)
                }
                Text("\(quantity)")
                    .font(.title)
                Button(action: {
                    quantity += 1
                }) {
                    Text("+")
                        .frame(width: 50, height: 50)
                        .background(Color.red.opacity(0.2)) // Rote Hintergrundfarbe mit Opazität
                        .cornerRadius(10)
                }
            }
            .padding()

            Button("Fertig") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
