import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import UIKit
//import MapKit
//import WeatherKit


struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var weather: String
    var photos: [Data]?
    var latitude: Double?
    var longitude: Double?
    var placeName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, date, weather, photos, latitude, longitude, placeName
    }
    
    // Custom initializer
    init(title: String = "",
         description: String = "",
         date: Date = Date(),
         weather: String = "",
         photos: [Data]? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         placeName: String? = nil) {
        self.title = title
        self.description = description
        self.date = date
        self.weather = weather
        self.photos = photos
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
    }
    
    // Custom encoding and decoding to handle optional values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
        weather = try container.decode(String.self, forKey: .weather)
        photos = try container.decodeIfPresent([Data].self, forKey: .photos)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        placeName = try container.decodeIfPresent(String.self, forKey: .placeName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(weather, forKey: .weather)
        try container.encodeIfPresent(photos, forKey: .photos)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(placeName, forKey: .placeName)
    }
    
    
    func prepareShareContent() -> [Any] {
        var itemsToShare: [Any] = []
        
        // Add text content
        itemsToShare.append(description)
        
        // Add images
        if let photosArray = photos {
                for imageData in photosArray {
                    if let image = UIImage(data: imageData) {
                        itemsToShare.append(image)
                    }
                }
            }

        
        return itemsToShare
    }
}
