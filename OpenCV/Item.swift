//
//  Item.swift
//  OpenCV
//
//  Created by Paul Leo on 28/06/2024.
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
