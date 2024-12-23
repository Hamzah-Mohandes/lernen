//
//  ContentView.swift
//  AI-BOT
//
//  Created by Hamzah on 13.11.24.
//

import SwiftUI


struct ContentView: View {
    
    var body: some View {
        TabView {
            TodoListView()
                .tabItem {
                    Label("Todo", systemImage: "list.bullet")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favoriten", systemImage: "heart")
                }
        }
    }
    
}



#Preview {
    ContentView()
}
