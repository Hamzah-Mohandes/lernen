import SwiftUI
import SwiftData
import Foundation


class OrderViewModel: ObservableObject {
    
    @Published var tables: [Table] = []
    @Published var drinks: [Drink] = []
    @Published var orders: [Order] = []
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        fetchTables()
        fetchDrinks()
        fetchOrders()
    }
    
    func fetchTables() {
        let fetchRequest = FetchDescriptor<Table>()
        do {
            tables = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching tables: \(error)")
        }
    }
    
    private func fetchDrinks() {
        let fetchRequest = FetchDescriptor<Drink>()
        do {
            drinks = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching drinks: \(error)")
        }
    }
    
    private func fetchOrders() {
        let fetchRequest = FetchDescriptor<Order>()
        do {
            orders = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching orders: \(error)")
        }
    }
    
    func addDrink(_ drink: Drink, to table: Table) {
        if let order = orders.first(where: { $0.table.id == table.id }) {
            if let index = order.items.firstIndex(where: { $0.id == drink.id }) {
                order.items[index].quantity += 1
            } else {
                var newItem = drink
                newItem.quantity = 1
                order.items.append(newItem)
            }
            // Replace context.update(order) with:
            do {
                try context.save()
            } catch {
                print("Error saving order: \(error)")
            }
        } else {
            var newItem = drink
            newItem.quantity = 1
            let newOrder = Order(table: table, items: [newItem])
            context.insert(newOrder)
            orders.append(newOrder)
            
            do {
                try context.save()
            } catch {
                print("Error saving order: \(error)")
            }
        }
    }
    
    func removeDrink(_ drink: Drink, from table: Table) {
        if let order = orders.first(where: { $0.table.id == table.id }) {
            if let index = order.items.firstIndex(where: { $0.id == drink.id }) {
                if order.items[index].quantity > 1 {
                    order.items[index].quantity -= 1
                } else {
                    order.items.remove(at: index)
                }
                // Replace with:
                do {
                    try context.save()
                } catch {
                    print("Error saving order: \(error)")
                }
            }
        }
    }
}
