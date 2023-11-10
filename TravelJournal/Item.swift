//
//  Item.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 10/26/23.
//

import Foundation
import SwiftData
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
