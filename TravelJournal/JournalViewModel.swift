import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit
import WeatherKit





class JournalViewModel: ObservableObject {
    @Published var journalEntries: [JournalEntry] = []
    
    @Published var placeName: String = ""
    private let geocoder = CLGeocoder()
    
//    @Published var selectedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var selectedCoordinate: EquatableCoordinate
    @Published var currentLocation: CLLocation?
    
    private var locationManager = LocationManager()
    private var locationUpdateCancellable: AnyCancellable?
    
    private let apiKey = "35FDfjmVfmPV83SFEf1TgURVDH3WFjh9"
    private let baseURL = "https://api.tomorrow.io/v4/timelines"
    @Published var weatherDescription: String = ""

    
    
//    init() {
//        locationUpdateCancellable = locationManager.$location.sink { [weak self] newLocation in
//            if let location = newLocation {
//                self?.selectedCoordinate = location.coordinate
//                self?.currentLocation = location
//                self?.getPlaceName(from: location)
//                
//            }
//        }
//    }
    init() {
        selectedCoordinate = EquatableCoordinate(coordinate: locationManager.location?.coordinate ?? CLLocationCoordinate2D())

        locationUpdateCancellable = locationManager.$location.sink { [weak self] newLocation in
            if let location = newLocation, let self = self {
                self.selectedCoordinate = EquatableCoordinate(coordinate: location.coordinate)
                self.currentLocation = location
                self.getPlaceName(from: location)
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
                print(error.localizedDescription)
                self.placeName = "Unknown Place"
                return
            }
            
            if let placemark = placemarks?.first {
                self.placeName = placemark.locality ?? "Unknown Place"
            }
        }
    }
    
    
    //     Function to perform forward geocoding
    //            func geocodeAddressString(_ addressString: String) {
    //                geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
    //                    guard let self = self else { return }
    //
    //                    if let error = error {
    //                        print("Geocoding error: \(error.localizedDescription)")
    //                        return
    //                    }
    //
    //                    if let placemark = placemarks?.first, let location = placemark.location {
    //                        self.selectedCoordinate = location.coordinate
    //                    }
    //                }
    //            }
    //
    func geocodeAddressString(_ addressString: String, completion: @escaping (CLLocationCoordinate2D) -> Void) {
        geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
            guard self != nil else { return }
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                completion(location.coordinate)
                _ = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self?.fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { weatherDescription in
                    
                    print(weatherDescription)
                }
            }
        }
    }
    
    
    
    //   function to get the documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
//    func addJournalEntry(_ entry: JournalEntry) {
//        journalEntries.append(entry)
//        saveJournalEntries()
//    }
    
    func addJournalEntry(_ entry: JournalEntry, at location: CLLocation) {
//        updateWeather(for: location) { weatherDescription in
//            var newEntry = entry
//            newEntry.weather = weatherDescription
//            self.journalEntries.append(newEntry)
//            self.saveJournalEntries()
//        }
        if let latitude = entry.latitude, let longitude = entry.longitude {
                let location = CLLocation(latitude: latitude, longitude: longitude)
            updateWeather(for: location) { weatherDescription in
                var newEntry = entry
                newEntry.weather = weatherDescription
                self.journalEntries.append(newEntry)
                self.saveJournalEntries()
            }
    }
        else {
                print("location data unavailable")
            }
        }
    
    func updateJournalEntry(_ updatedEntry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            journalEntries[index] = updatedEntry
            saveJournalEntries()
        }
    }
    
    
    
    //weather functionalities
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        let apiKey = "35FDfjmVfmPV83SFEf1TgURVDH3WFjh9"
        let urlString = "https://api.tomorrow.io/v4/weather/realtime?location=\(latitude),\(longitude)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                    let decodedResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let weatherCode = decodedResponse.data.timelines.first?.intervals.first?.values.weatherCode {
                            let weatherDesc = self?.decodeWeatherCode(weatherCode)
//                            self?.weatherDescription = "Weather: \(weatherDesc ?? "Unknown")"
                            completion("Weather: \(weatherDesc ?? "Unknown")")
                        }
                    }
                } catch {
                    print("Failed to decode weather data: \(error)")
                }
        }.resume()
    }
    
    func updateWeather(for location: CLLocation, completion: @escaping (String) -> Void) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        fetchWeatherData(latitude: latitude, longitude: longitude, completion: completion)
        
    }

    
    
    func decodeWeatherCode(_ code: Int) -> String {
        switch code {
        case 0: return "Unknown"
        case 1000: return "Clear, Sunny"
        case 1100: return "Mostly Clear"
        case 1101: return "Partly Cloudy"
        case 1102: return "Mostly Cloudy"
        case 1001: return "Cloudy"
        case 2000: return "Fog"
        case 2100: return "Light Fog"
        case 4000: return "Drizzle"
        case 4001: return "Rain"
        case 4200: return "Light Rain"
        case 4201: return "Heavy Rain"
        case 5000: return "Snow"
        case 5001: return "Flurries"
        case 5100: return "Light Snow"
        case 5101: return "Heavy Snow"
        case 6000: return "Freezing Drizzle"
        case 6001: return "Freezing Rain"
        case 6200: return "Light Freezing Rain"
        case 6201: return "Heavy Freezing Rain"
        case 7000: return "Ice Pellets"
        case 7101: return "Heavy Ice Pellets"
        case 7102: return "Light Ice Pellets"
        case 8000: return "Thunderstorm"
        default: return "Unknown Weather"
        }
    }
    
}



struct WeatherResponse: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let timelines: [Timeline]
}

struct Timeline: Codable {
    let intervals: [Interval]
}

struct Interval: Codable {
    let values: WeatherValues
}

struct WeatherValues: Codable {
    let weatherCode: Int
}




//struct WeatherResponse: Codable {
//    let main: Main
//    let weather: [Weather]
//}
//
//struct Main: Codable {
//    let temp: Double
//}
//
//struct Weather: Codable {
//    let main: String
//}
