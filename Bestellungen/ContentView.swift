import SwiftUI
import SwiftData


struct ContentView: View {
    @StateObject private var viewModel: OrderViewModel

    init() {
        do {
            let container = try ModelContainer(for: Table.self, Drink.self, Order.self)
            _viewModel = StateObject(wrappedValue: OrderViewModel(context: container.mainContext))
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some View {
        NavigationStack {
            ContentViewBody(viewModel: viewModel)
        }
    }
}

struct ContentViewBody: View {
    @ObservedObject var viewModel: OrderViewModel

    var body: some View {
        CategoryView(viewModel: viewModel, table: Table(number: 1))
    }
    ()}

struct CategoryView: View {
    @ObservedObject var viewModel: OrderViewModel
    var table: Table

    var body: some View {
        VStack {
            Text("Categories for Table \(table.number)")
                .font(.title)
                .padding()

            List {
                NavigationLink(destination: DrinksView(table: table, viewModel: viewModel)) {
                    Text("Getränke")
                }
                NavigationLink(destination: KitchenView()) {
                    Text("Küchen")
                }
            }
        }
        .navigationTitle("Categories")
    }
}

struct DrinksView: View {
    var table: Table
    @ObservedObject var viewModel: OrderViewModel

    var body: some View {
        VStack {
            Text("Getränke für Tisch \(table.number)")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(viewModel.drinks, id: \.id) { drink in
                    HStack {
                        Text("\(drink.name) - \(String(format: "%.2f", drink.price)) €")
                        Spacer()
                        Button(action: {
                            viewModel.addDrink(drink, to: table)
                        }) {
                            Text("+")
                                .font(.title)
                                .padding(.horizontal)
                                .foregroundColor(.green)
                        }
                        Button(action: {
                            viewModel.removeDrink(drink, from: table)
                        }) {
                            Text("-")
                                .font(.title)
                                .padding(.horizontal)
                                .foregroundColor(.red)
                        }
                        Text("\(viewModel.count(for: drink, at: table))")
                            .padding(.horizontal)
                    }
                }
            }
            Text("Gesamt: \(String(format: "%.2f", viewModel.total(for: table))) €")
                .font(.title)
                .padding()
        }
        .navigationTitle("Getränke")
    }
}

struct KitchenView: View {
    var body: some View {
        VStack {
            Text("Küchen")
                .font(.largeTitle)
                .padding()

            List {
                Text("Pizza")
                Text("Pasta")
                Text("Burger")
            }
        }
        .navigationTitle("Küchen")
    }
}

@Model
class Drink {
    var id: UUID = UUID()
    var name: String
    var price: Double

    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
}




@Model
class OrderItem {
    var id: UUID = UUID()
    var drink: Drink
    var quantity: Int

    init(drink: Drink, quantity: Int) {
        self.drink = drink
        self.quantity = quantity
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
