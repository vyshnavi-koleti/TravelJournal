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
    

    @Published var currentLocation: CLLocation?
    
    private var locationManager = LocationManager()
    private var locationUpdateCancellable: AnyCancellable?
    
    private let apiKey = "35FDfjmVfmPV83SFEf1TgURVDH3WFjh9"
    private let baseURL = "https://api.tomorrow.io/v4/timelines"
    @Published var weatherDescription: String = ""

    
    
    init() {
        locationUpdateCancellable = locationManager.$location.sink { [weak self] newLocation in
            if let location = newLocation {
                self?.currentLocation = location
              self?.getPlaceName(from: location) { placeName in
                    DispatchQueue.main.async {
                        self?.placeName = placeName
                    }
                }
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
    
    
    
    func getPlaceName(from location: CLLocation, completion: @escaping (String) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                completion("Unknown Place")
                return
            }
            if let placemark = placemarks?.first {
                let placeName = placemark.locality ?? "Unknown Place"
                completion(placeName)
            }
        }
    }


    
    
//         Function to perform forward geocoding - working
    func geocodeAddressString(_ addressString: String, completion: @escaping (CLLocationCoordinate2D) -> Void) {
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first, let location = placemark.location {
                completion(location.coordinate)
            }
        }
    }



    
    
    


    func fetchWeatherForPlaceName(_ placeName: String, completion: @escaping (String) -> Void) {
        geocodeAddressString(placeName) { [weak self] coordinates in
            self?.fetchWeatherData(latitude: coordinates.latitude, longitude: coordinates.longitude) { weatherDescription in
                DispatchQueue.main.async {
                    completion(weatherDescription)
                }
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
    
    
    
    //weather functionalities
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        let urlString = "https://api.tomorrow.io/v4/weather/realtime?location=\(latitude),\(longitude)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                completion("Error fetching weather data")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    let weatherDesc = self.decodeWeatherCode(decodedResponse.data.values.weatherCode)
                    completion(weatherDesc)
                }
            } catch {
                print("Failed to decode weather data: \(error)")
                completion("Decoding error")
            }
        }.resume()
    }
    
    
    func updateLocationAndWeather(forPlaceName placeName: String) {
        geocodeAddressString(placeName) { [weak self] newCoordinates in
            let newLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
            self?.currentLocation = newLocation
            self?.fetchWeatherData(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude) { weatherDescription in
                DispatchQueue.main.async {
                    self?.weatherDescription = weatherDescription
                }
            }
        }
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
    let data: WeatherData
    let location: Location
}

struct WeatherData: Codable {
    let time: String
    let values: WeatherValues
}

struct WeatherValues: Codable {
    let weatherCode: Int
    
}

struct Location: Codable {
    let lat: Double
    let lon: Double

}



