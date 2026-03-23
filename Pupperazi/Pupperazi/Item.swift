//
//  Item.swift
//  Pupperazi
//
//  Created by Ben Artis on 3/23/26.
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
