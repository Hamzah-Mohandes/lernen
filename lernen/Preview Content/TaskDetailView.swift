//
//  TaskDetailView.swift
//  lernen
//
//  Created by Hamzah on 08.11.24.
//

import SwiftUI
struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    var task: Task

    @State private var newCommentText = ""

    var body: some View {
        VStack {
            HStack {
                Text(task.title)
                    .font(.title)
                    .padding()

                Spacer()

                Button(action: {
                    task.isFavorite.toggle()
                    // Änderungen werden automatisch gespeichert
                }) {
                    Image(systemName: task.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(task.isFavorite ? .red : .gray)
                }
            }

            List(task.comments ?? []) { comment in
                Text(comment.text)
            }

            HStack {
                TextField("New Comment", text: $newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if !newCommentText.isEmpty {
                        let comment = Comment(text: newCommentText)
                        comment.task = task
                        modelContext.insert(comment)
                        newCommentText = ""
                    }
                }) {
                    Text("Add Comment")
                }
                .disabled(newCommentText.isEmpty)
            }
        }
        .navigationTitle("Task Details")
    }
}
