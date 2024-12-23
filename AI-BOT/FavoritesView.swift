import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todoItems: [TodoItem]

    var body: some View {
        NavigationView {
            List(todoItems.filter { $0.favorite }) { todoItem in
                HStack {
                    Text(todoItem.title)
                        .font(.headline)
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                        
                        
                    Spacer()
                    if todoItem.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    if todoItem.favorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                            .foregroundColor(.gray)
                            
                    }
                }
                .onTapGesture {
                    toggleCompletion(for: todoItem)
                }
                .onLongPressGesture {
                    toggleFavorite(for: todoItem)
                }
            }
            .navigationTitle("Favorites")
        }
    }

    private func toggleCompletion(for todoItem: TodoItem) {
        todoItem.isCompleted.toggle()
        saveContext()
    }

    private func toggleFavorite(for todoItem: TodoItem) {
        todoItem.favorite.toggle() // Favoritenstatus ändern
        saveContext() // Speichern der Änderungen
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

