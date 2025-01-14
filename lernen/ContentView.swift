//
//  ContentView.swift
//  lernen
//
//  Created by Hamzah on 05.11.24.
//


import SwiftUI
import SwiftData

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
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tasks Tab
            NavigationView {
                VStack {
                    HStack {
                        TextField("Neue Aufgabe", text: $newTaskTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: {
                            if !newTaskTitle.isEmpty {
                                let task = Task(title: newTaskTitle)
                                modelContext.insert(task)
                                newTaskTitle = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                    
                    List {
                        ForEach(tasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                HStack {
                                    Text(task.title)
                                    Spacer()
                                    if task.isFavorite {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteTasks)
                    }
                }
                .navigationTitle("Aufgaben")
            }
            .tabItem {
                Label("Aufgaben", systemImage: "list.bullet")
            }
            .tag(0)
            
            // Favoriten Tab
            NavigationView {
                List {
                    ForEach(tasks.filter { $0.isFavorite }) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            Text(task.title)
                        }
                    }
                }
                .navigationTitle("Favoriten")
            }
            .tabItem {
                Label("Favoriten", systemImage: "heart.fill")
            }
            .badge(tasks.filter { $0.isFavorite }.count)
            .tag(1)
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}




