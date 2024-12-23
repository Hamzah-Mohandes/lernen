//
//  Product.swift
//  lernen
//
//  Created by Hamzah on 06.12.24.
//

import Foundation
import SwiftData

@Model
class Product {
    var id: UUID
    var name: String
    var price: Double
    var category: Category

    init(id: UUID = UUID(), name: String, price: Double, category: Category) {
        self.id = id
        self.name = name
        self.price = price
        self.category = category
    }
}
