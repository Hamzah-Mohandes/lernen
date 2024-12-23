//
//  lernenApp.swift
//  lernen
//
//  Created by Hamzah on 05.11.24.
//

import SwiftUI
import SwiftData

@main
struct lernenApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: Task.self)
        }
        
    }
}
