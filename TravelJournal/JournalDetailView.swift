import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit

struct JournalDetailView: View {
    let entry: JournalEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(entry.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Date
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
//                 Location
                if let latitude = entry.latitude, let longitude = entry.longitude {
                    Text("Location: \(latitude), \(longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Location: Not Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
//                if let location = entry.location {
//                    Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
                
                // Weather
                Text("Weather: \(entry.weather ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Description
                Text(entry.description)
                    .font(.body)
                
                // Photos
                if let photosData = entry.photos {
                                    ForEach(photosData.indices, id: \.self) { index in
                                        if let uiImage = UIImage(data: photosData[index]) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                        }
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                }
                
//            Will add more UI elements as needed
                Button("Edit") {
                            // Navigate to the JournalEntryEditView
                        }
            }
            .padding()
        }
        .navigationBarTitle("Journal Entry", displayMode: .inline)
    }
}
