//
//  ContentView.swift
//  lernen
//
//  Created by Hamzah on 05.11.24.
//


import SwiftUI
import SwiftData
import Foundation


@Model
class Task {
    var title: String
    var isFavorite: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Comment.task)
    var comments: [Comment]?

    init(title: String) {
        self.title = title
    }
}

@Model
class Comment {
    var text: String
    var task: Task?

    init(text: String) {
        self.text = text
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    @State private var newTaskTitle = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        if !newTaskTitle.isEmpty {
                            let task = Task(title: newTaskTitle)
                            modelContext.insert(task)
                            newTaskTitle = ""
                        }
                    }) {
                        Text("Add Task")
                    }
                    .disabled(newTaskTitle.isEmpty)
                }

                List {
                    ForEach(tasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            Text(task.title)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                modelContext.delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(action: {
                                task.isFavorite.toggle()
                                // Änderungen werden automatisch gespeichert
                            }) {
                                Image(systemName: task.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(task.isFavorite ? .red : .gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("To-Do List")
        }
    }
}




