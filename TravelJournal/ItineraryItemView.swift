//
//  ItineraryItemView.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 12/8/23.
//

import Foundation
import Combine
import SwiftUI

struct ItineraryItemView: View {
    var item: ItineraryItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Destination and Dates
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.destination)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("\(item.startDate, formatter: itemDateFormatter) - \(item.endDate, formatter: itemDateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)

                Divider()

                // Activities
                VStack(alignment: .leading, spacing: 10) {
                    Text("Activities")
                        .font(.headline)
                        .padding(.bottom, 5)

                    ForEach(item.activities) { activity in
                        VStack(alignment: .leading) {
                            Text(activity.title)
                                .font(.headline)
                            Text(activity.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                            Text("Time: \(activity.time, formatter: timeFormatter)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 5)
                    }
                }

                Divider()

                // Notes
                if !item.notes.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text(item.notes)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Itinerary Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var itemDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}


//struct ItineraryItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItineraryItemView(item: ItineraryItem(
//            destination: "Paris",
//            startDate: Date(),
//            endDate: Date().addingTimeInterval(86400),
//            activities: [
//                Activity(title: "Eiffel Tower Visit", description: "Tour of the Eiffel Tower", time: Date().addingTimeInterval(3600)),
//                Activity(title: "Louvre Museum", description: "Visit the Louvre Museum", time: Date().addingTimeInterval(7200))
//            ],
//            notes: "Remember to bring a camera!"
//        ))
//    }
//}
