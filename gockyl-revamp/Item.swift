//
//  Item.swift
//  gockyl-revamp
//
//  Created by Ivandohan Samuel Siregar on 04/07/26.
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
