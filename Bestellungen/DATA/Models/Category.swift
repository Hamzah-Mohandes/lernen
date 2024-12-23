//
//  Category.swift
//  lernen
//
//  Created by Hamzah on 06.12.24.
//

import Foundation
import SwiftData

@Model

class Category {
    var id = UUID() // UUID macht die ID eindeutig und unvergesslich
    var name: String
    
    // wir schreiben ein Konstruktor
    init(name: String) {
        self.name = name
    }
}
