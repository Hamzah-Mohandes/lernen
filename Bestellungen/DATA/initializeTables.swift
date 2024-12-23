//
//  initializeTables.swift
//  lernen
//
//  Created by Hamzah on 06.12.24.
//
import SwiftData

func initializeTables(context: ModelContext) {
    // Überprüfen, ob bereits Tische vorhanden sind, um Duplikate zu vermeiden
    let fetchRequest = FetchDescriptor<Table>()
    do {
        let existingTables = try context.fetch(fetchRequest)
        if !existingTables.isEmpty {
            print("Tables already initialized.")
            return
        }
    } catch {
        print("Failed to fetch existing tables: \(error)")
    }

    // Tische von 1 bis 30 erstellen
    for number in 1...30 {
        let table = Table(number: number)
        context.insert(table)
    }

    // Änderungen speichern
    do {
        try context.save()
        print("Tables initialized successfully.")
    } catch {
        print("Failed to save tables: \(error)")
    }
}
