//
//  ItineraryModels.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 12/8/23.
//

import Foundation
import Combine
import SwiftUI


struct ItineraryItem: Identifiable, Codable {
    var id = UUID()
    var destination: String
    var startDate: Date
    var endDate: Date
    var activities: [Activity]
    var notes: String
}

struct Activity: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var time: Date
}
