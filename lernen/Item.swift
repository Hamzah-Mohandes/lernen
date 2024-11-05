//
//  Item.swift
//  lernen
//
//  Created by Hamzah on 05.11.24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
