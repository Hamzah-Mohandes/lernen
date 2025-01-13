//
//  ContentView.swift
//  chalenge
//
//  Created by Hamzah on 19.11.24.
//

import SwiftUI

// Todo Model direkt in ContentView.swift
struct Todo: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct ContentView: View {
    @State private var todos = [
        Todo(title: "SwiftUI lernen", isCompleted: false),
        Todo(title: "App entwickeln", isCompleted: false),
        Todo(title: "Code committen", isCompleted: true)
    ]
    @State private var newTodoTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Neue Aufgabe", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    Button(action: addTodo) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding()
                
                List {
                    ForEach(todos) { todo in
                        HStack {
                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(todo.isCompleted ? .green : .gray)
                                .onTapGesture {
                                    toggleTodo(todo)
                                }
                            
                            Text(todo.title)
                                .strikethrough(todo.isCompleted)
                                .foregroundColor(todo.isCompleted ? .gray : .white)
                        }
                    }
                    .onDelete(perform: deleteTodos)
                }
            }
            .navigationTitle("Meine Aufgaben")
            .background(Color.black)
            .foregroundColor(.white)
        }
        .preferredColorScheme(.dark)
    }
    
    private func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        todos.append(Todo(title: newTodoTitle, isCompleted: false))
        newTodoTitle = ""
    }
    
    private func toggleTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
