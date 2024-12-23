//
//  FavoritesView.swift
//  lernen
//
//  Created by Hamzah on 08.11.24.
//

import SwiftUI
import _SwiftData_SwiftUI

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    var body: some View {
        List {
            ForEach(tasks.filter { $0.isFavorite }) { task in
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
            }
        }
        .navigationTitle("Favorites")
    }
}



