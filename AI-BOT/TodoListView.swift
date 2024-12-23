//
//  TodoListView.swift
//  AI-BOT
//
//  Created by Hamzah on 17.11.24.
//
import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todoItems: [TodoItem]

    @State private var newTodoTitle: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(todoItems) { todoItem in
                        HStack {
                            Text(todoItem.title)
                                
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
                    .onDelete(perform: deleteTodoItems)
                }

                HStack {
                    TextField("New Todo", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button(action: addTodoItem) {
                        Text("Add")
                    }
                    .padding()
                }
            }
            .navigationTitle("Todo List")
        }
    }

    private func addTodoItem() {
        guard !newTodoTitle.isEmpty else { return }
        let newTodo = TodoItem(title: newTodoTitle, isCompleted: false, dueData: nil, favorite: false)
        modelContext.insert(newTodo)
        newTodoTitle = ""
    }

    private func toggleCompletion(for todoItem: TodoItem) {
        todoItem.isCompleted.toggle()
        saveContext()
    }

    private func toggleFavorite(for todoItem: TodoItem) {
        todoItem.favorite.toggle() // Favoritenstatus ändern
        saveContext() // Speichern der Änderungen
    }

    private func deleteTodoItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(todoItems[index])
        }
        saveContext()
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

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
            .modelContainer(for: TodoItem.self, inMemory: true)
    }
}
