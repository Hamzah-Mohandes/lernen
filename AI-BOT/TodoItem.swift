//
//  Model.swift
//  lernen
//
//  Created by Hamzah on 17.11.24.
//

import Foundation
import SwiftData

@Model
class TodoItem {
    var id: UUID
    var title : String
    var isCompleted : Bool
    var dueData : Date? // wir die date nicht definiert haben
    var favorite : Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool, dueData: Date?, favorite: Bool) { // mit init koennen wir die daten in die variables schreiben
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueData = dueData
        self.favorite = favorite
    }
}
