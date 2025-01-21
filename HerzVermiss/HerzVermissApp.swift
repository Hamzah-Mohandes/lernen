//
//  HerzVermissApp.swift
//  HerzVermiss
//
//  Created by Hamzah on 14.01.25.
//

import SwiftUI
import SwiftData

@main
struct HerzVermissApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
      .modelContainer(for: Todo.self) // SwiftData-Container für das Todo-Modell
    }
}
