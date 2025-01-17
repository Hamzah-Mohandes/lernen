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
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
        .modelContainer(for: Todo.self)
    }
}
