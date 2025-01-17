//
//  amazonApp.swift
//  amazon
//
//  Created by Hamzah on 22.11.24.
//


import SwiftUI
import SwiftData

@main
struct amazonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Aufgabe.self)
        }
    }
}
