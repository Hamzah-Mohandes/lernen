//
//  tag1App.swift
//  tag1
//
//  Created by Hamzah on 13.11.24.
//

import SwiftUI
import SwiftData

@main
struct tag1App: App {
    @StateObject var orderManager = OrderManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(orderManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
