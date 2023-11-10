import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var weather: String?
    var photos: [Data]?
    var latitude: Double?
    var longitude: Double?
    
//    var location: CLLocation?
    

//    var recordID: CKRecord.ID?


    
    // Initializing with default values
    init(title: String = "",
         description: String = "",
         date: Date = Date(),
         weather: String? = nil,
         photos: [Data]? = nil,
         location: CLLocation? = nil)
//        recordID: CKRecord.ID? = nil)
    //         location: CLLocation? = nil,
    {
        self.title = title
        self.description = description
        self.date = date
        self.weather = weather
        self.photos = photos
        self.latitude = location?.coordinate.latitude
        self.longitude = location?.coordinate.longitude
//        self.recordID = recordID
//        self.location = location

    }
}

