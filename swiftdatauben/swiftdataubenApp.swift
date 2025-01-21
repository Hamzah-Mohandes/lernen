//
//  swiftdataubenApp.swift
//  swiftdatauben
//
//  Created by Hamzah on 20.01.25.
//

import SwiftUI
import SwiftData

@main
struct swiftdataubenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Todo.self) // SwiftData-Container für das Todo-Modell
    }
}
