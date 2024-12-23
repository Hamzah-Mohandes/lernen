//
//  Tisch.swift
//  lernen
//
//  Created by Hamzah on 06.12.24.
//

import Foundation
import SwiftData

@Model
class Table {
    var number: Int
    var orders: [Order]

    init(number: Int) {
        self.number = number
        self.orders = []
    }
}

