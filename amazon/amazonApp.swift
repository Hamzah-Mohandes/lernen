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
    // MARK: - Model Container Setup
    let container: ModelContainer
    
    init() {
        do {
            // Erstelle einen ModelContainer für unser Notiz-Modell
            container = try ModelContainer(for: Notiz.self)
        } catch {
            // Fehlerbehandlung, falls die Initialisierung fehlschlägt
            fatalError("Fehler beim Erstellen des ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Stelle den ModelContainer der gesamten App zur Verfügung
                .modelContainer(container)
        }
    }
}
