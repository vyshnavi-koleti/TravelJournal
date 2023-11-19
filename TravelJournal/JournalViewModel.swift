import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit




class JournalViewModel: ObservableObject {
    @Published var journalEntries: [JournalEntry] = []
    
    @Published var placeName: String = ""
    private let geocoder = CLGeocoder()
    
    @Published var selectedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var currentLocation: CLLocation?

       private var locationManager = LocationManager()
       private var locationUpdateCancellable: AnyCancellable?
    
    
    init() {
            locationUpdateCancellable = locationManager.$location.sink { [weak self] newLocation in
                if let location = newLocation {
                    self?.selectedCoordinate = location.coordinate
                    self?.currentLocation = location
                    self?.getPlaceName(from: location)
                }
            }
        }
    
//    Function to load entriess from local storage
    func loadJournalEntries() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("journalEntries.json")
        
        // Checking if the file exists before trying to load it
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                journalEntries = try JSONDecoder().decode([JournalEntry].self, from: data)
                print("Loaded journal entries: \(journalEntries)") // Console output for loaded data
            } catch {
                print("Error loading journal entries: \(error)")
            }
        } else {
            print("Journal entries file does not exist. This may be the first app launch.")
            // Optionally, create an empty file or handle this case as needed.
        }
    }
    
//     Function to save journal entries to local storage
    func saveJournalEntries() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("journalEntries.json")
        do {
            let data = try JSONEncoder().encode(journalEntries)
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
            print("Journal entries saved successfully.")
        } catch {
            print("Error saving journal entries: \(error)")
        }
    }
//    function for place name
    func getPlaceName(from location: CLLocation) {
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                
                if let error = error {
                    // Handle the error case
                    print(error.localizedDescription)
                    self.placeName = "Unknown Place"
                    return
                }
                
                if let placemark = placemarks?.first {
                    // Here you can extract more detailed address components if needed
                    self.placeName = placemark.locality ?? "Unknown Place"
                }
            }
        }
    
//     Function to perform forward geocoding
        func geocodeAddressString(_ addressString: String) {
            geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }

                if let placemark = placemarks?.first, let location = placemark.location {
                    self.selectedCoordinate = location.coordinate
                }
            }
        }
    
    
    
    
//   function to get the documents directory
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    
    
    
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveJournalEntries()
    }
    
    func updateJournalEntry(_ updatedEntry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            journalEntries[index] = updatedEntry
            saveJournalEntries()
        }
    }
    
}
