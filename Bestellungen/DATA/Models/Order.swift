//
//  Order.swift
//  lernen
//
//  Created by Hamzah on 06.12.24.
//


import Foundation
import SwiftData

@Model
class Order {
    var table: Table
    var items: [Drink]

    init(table: Table, items: [Drink]) {
        self.table = table
        self.items = items
    }
}
