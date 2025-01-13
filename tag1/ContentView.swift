
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
    @Published var completedOrders: [(table: Int, item: String)] = [] // Liste der abgeschlossenen Bestellungen mit Tischnummer
    @Published var tablePrices: [Int: Double] = [:] // Preis für jeden Tisch
    @Published var orders: [Int: [String: Int]] = [:] // Bestellungen für jeden Tisch mit Anzahl
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
        .accentColor(.blue) // Setze die Akzentfarbe auf Blau
    }
}

struct HomeView: View {
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(orderManager.completedOrders, id: \.item) { order in
                        HStack {
                            Text("✅ Tisch \(order.table): \(order.item) ist fertig!")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .transition(.slide) // Animation für neue Einträge
                        }
                    }
                }
                .navigationTitle("Fertige Bestellungen 🎉")
            }
        }
    }
}

struct KitchenView: View {
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    var body: some View {
        VStack {
            Text("Küchenansicht 🍳")
                .font(.largeTitle)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .shadow(radius: 5)

            if orderManager.orderedTables.isEmpty {
                Text("Keine Bestellungen. 🕸️")
                    .foregroundColor(.gray)
                    .padding()
                    .transition(.slide) // Animation für leere Liste
            } else {
                List(orderManager.orderedTables, id: \.self) { table in
                    VStack(alignment: .leading, spacing: 10) {
                        // Tischnummer oben
                        Text("🍽️ Tisch \(table)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)

                        // Bestellungen anzeigen
                        if let orders = orderManager.orders[table] {
                            ForEach(Array(orders.keys), id: \.self) { item in
                                HStack {
                                    Text(item)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(orders[item] ?? 0)x")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // "Fertig"-Button unten
                        Button(action: {
                            withAnimation {
                                markOrderAsCompleted(table: table)
                            }
                        }) {
                            Text("Fertig 🎉")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
            }
        }
        .padding()
    }

    private func markOrderAsCompleted(table: Int) {
        if let orders = orderManager.orders[table] {
            for (order, quantity) in orders {
                for _ in 0..<quantity {
                    orderManager.completedOrders.append((table: table, item: order)) // Speichere Tischnummer und Bestellung
                }
            }
        }
        orderManager.orderedTables.removeAll { $0 == table }
        orderManager.orders[table] = nil
    }
}

struct WaiterView: View {
    let tables = Array(1...30)
    @State private var quantities: [Int] = Array(repeating: 0, count: 100)
    @State private var selectedItem: (String, Int)?
    @State private var showingSheet = false
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    // Getränkeliste: Kalt und Warm
    let coldDrinks = [
        ("🥤 Cola", 2.5),
        ("🍊 Fanta", 2.5),
        ("💧 Wasser", 1.5),
        ("🍎 Apfelsaft", 3.0),
        ("🍵 Eistee", 2.8)
    ]
    
    let hotDrinks = [
        ("☕ Kaffee", 2.0),
        ("🍵 Tee", 1.8),
        ("☕ Cappuccino", 3.0),
        ("☕ Latte Macchiato", 3.5),
        ("🍫 Heiße Schokolade", 3.2)
    ]

    // Frühstücksliste
    let breakfastItems = [
        ("🍳 Rührei", 4.5),
        ("🥓 Speck", 3.0),
        ("🍞 Toast", 2.0),
        ("🥐 Croissant", 3.5),
        ("🥞 Pfannkuchen", 5.0),
        ("🧀 Käseplatte", 6.0),
        ("🍓 Obstsalat", 4.0)
    ]

    var body: some View {
        NavigationView {
            List(tables, id: \.self) { table in
                NavigationLink(destination: TableDetailView(table: table, quantities: $quantities, showingSheet: $showingSheet, selectedItem: $selectedItem)) {
                    HStack {
                        Text("🍽️ Tisch \(table)")
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .shadow(radius: 2)

                        Spacer()

                        Text("\(orderManager.tablePrices[table] ?? 0.0, specifier: "%.2f") €")
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }
                }
            }
            .navigationTitle("Tische 🍴")
        }
    }
}

struct TableDetailView: View {
    let table: Int
    @Binding var quantities: [Int]
    @Binding var showingSheet: Bool
    @Binding var selectedItem: (String, Int)?
    @EnvironmentObject var orderManager: OrderManager // Zugriff auf den OrderManager

    // Getränkeliste: Kalt und Warm
    let coldDrinks = [
        ("🥤 Cola", 2.5),
        ("🍊 Fanta", 2.5),
        ("💧 Wasser", 1.5),
        ("🍎 Apfelsaft", 3.0),
        ("🍵 Eistee", 2.8)
    ]
    
    let hotDrinks = [
        ("☕ Kaffee", 2.0),
        ("🍵 Tee", 1.8),
        ("☕ Cappuccino", 3.0),
        ("☕ Latte Macchiato", 3.5),
        ("🍫 Heiße Schokolade", 3.2)
    ]

    // Frühstücksliste
    let breakfastItems = [
        ("🍳 Rührei", 4.5),
        ("🥓 Speck", 3.0),
        ("🍞 Toast", 2.0),
        ("🥐 Croissant", 3.5),
        ("🥞 Pfannkuchen", 5.0),
        ("🧀 Käseplatte", 6.0),
        ("🍓 Obstsalat", 4.0)
    ]

    var body: some View {
        List {
            Section(header: Text("Kalte Getränke 🧊").font(.headline)) {
                ForEach(coldDrinks.indices, id: \.self) { index in
                    createButton(for: coldDrinks[index].0, price: coldDrinks[index].1, at: index)
                }
            }
            
            Section(header: Text("Warme Getränke ☕").font(.headline)) {
                ForEach(hotDrinks.indices, id: \.self) { index in
                    createButton(for: hotDrinks[index].0, price: hotDrinks[index].1, at: index + coldDrinks.count)
                }
            }
            
            Section(header: Text("Frühstück 🍳").font(.headline)) {
                ForEach(breakfastItems.indices, id: \.self) { index in
                    createButton(for: breakfastItems[index].0, price: breakfastItems[index].1, at: index + coldDrinks.count + hotDrinks.count)
                }
            }
        }
        .navigationTitle("Tisch \(table) 🍽️")
        .sheet(isPresented: Binding(
            get: { showingSheet && selectedItem != nil },
            set: { showingSheet = $0 }
        )) {
            if let selectedItem = selectedItem {
                QuantitySelectionView(item: selectedItem.0, quantity: $quantities[selectedItem.1])
                    .onDisappear {
                        withAnimation {
                            if !orderManager.orderedTables.contains(table) {
                                orderManager.orderedTables.append(table)
                            }
                            let totalPrice = calculateTotalPrice()
                            orderManager.tablePrices[table] = totalPrice
                            orderManager.orders[table, default: [:]][selectedItem.0, default: 0] += quantities[selectedItem.1]
                        }
                    }
            }
        }
    }

    private func createButton(for item: String, price: Double, at index: Int) -> some View {
        Button(action: {
            selectedItem = (item, index)
            showingSheet = true
        }) {
            HStack {
                Text(item)
                Spacer()
                Text("\(quantities[index])")
                Text("\(price, specifier: "%.2f") €")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private func calculateTotalPrice() -> Double {
        return quantities.reduce(0) { $0 + Double($1) * 1.5 }
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
                    withAnimation {
                        if quantity > 0 {
                            quantity -= 1
                        }
                    }
                }) {
                    Text("-")
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                Text("\(quantity)")
                    .font(.title)
                Button(action: {
                    withAnimation {
                        quantity += 1
                    }
                }) {
                    Text("+")
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding()

            Button("Fertig 🎉") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

