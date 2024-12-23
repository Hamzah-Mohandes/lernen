import SwiftUICore
import SwiftUI

//
//  MainView.swift
//  lernen
//
//  Created by Hamzah on 08.11.24.
//

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
    }
}
