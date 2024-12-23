//
//  BestellungenApp.swift
//  Bestellungen
//
//  Created by Hamzah on 06.12.24.
//

import SwiftUI
import SwiftData


@main
struct BestellungenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Category.self, Item.self, Order.self, Product.self, Table.self])

               
            
        }
    }
}
