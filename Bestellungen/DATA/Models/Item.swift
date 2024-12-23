//
//  Item.swift
//  lernen
//
//  Created by Hamzah on 06.12.24.
//

import Foundation
import SwiftData


@Model
class Item: Hashable, Identifiable {
    var id = UUID()
    var name: String
    var price: Double
    
    
    
    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
}
