//
//  AI_BOTApp.swift
//  AI-BOT
//
//  Created by Hamzah on 13.11.24.
//

import SwiftUI
import SwiftData
import CoreData


@main
struct AI_BOTApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: TodoItem.self, inMemory: true)
              
        }
    }
}
