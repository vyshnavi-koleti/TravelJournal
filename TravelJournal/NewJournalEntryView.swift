import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit



struct NewJournalEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Binding var journalEntries: [JournalEntry]
    @ObservedObject var locationManager = LocationManager()
    var saveAction: () -> Void
    private var locationUpdateCancellable: AnyCancellable?
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var weather = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uiImages = [Data]()
    @State private var placeName: String = "Loading..."
    @State private var showingMap = false
    @State private var selectedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()


    
    //    @State private var selectedImages = [Image]()
    //    @State private var uiImages = [UIImage]()
    @Environment(\.presentationMode) var presentationMode
    
    
    init(viewModel: JournalViewModel, journalEntries: Binding<[JournalEntry]>, saveAction: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._journalEntries = journalEntries
        self.saveAction = saveAction
        self.locationManager = LocationManager()
        
//        locationUpdateCancellable = locationManager.$location.sink { newLocation in
//            if let location = newLocation {
//                self.reverseGeocode(location: location)
//            }
//        }
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Weather", text: $weather)
                    .keyboardType(.default)
                
                //                Location
                Section(header: Text("Location")) {
                    if let location = locationManager.location {
                        Text("Current Location: \(selectedCoordinate.latitude), \(selectedCoordinate.longitude)")
                        TextField("Place Name", text: $placeName)
                    } else {
                        Text("Location: Not Available")
                    }
                    Button("Choose on Map") {
                        showingMap = true
                    }
                }
                
                
                //                DatePicker for selecting date
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                //              Photo picker
                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
                
                    .onChange(of: selectedItems) { newValue, _ in
                        Task {
                            uiImages.removeAll()
                            for item in selectedItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    uiImages.append(data)
                                }
                            }
                        }
                    }
            }
            .navigationBarTitle("New Entry")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveEntry()
            })
            .sheet(isPresented: $showingMap) {
                MapView(selectedCoordinate: $selectedCoordinate,
                        initialLocation: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
                        onConfirm: { location in
                    let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.selectedCoordinate = newLocation.coordinate // Update the selectedCoordinate
                    self.locationManager.location = newLocation
                    self.reverseGeocode(location: newLocation)
                })
            }
            
            
        }
    }

    
    
    func saveEntry() {
        let newEntry = JournalEntry(
            title: title,
            description: description,
            date: selectedDate,
            weather: weather,
            photos: uiImages,
            location: locationManager.location
        )
        journalEntries.append(newEntry)
        saveAction()
        presentationMode.wrappedValue.dismiss()
    }
    
    
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                // Handle the error case
                print(error.localizedDescription)
                self.placeName = "Unable to find place name"
            } else if let placemark = placemarks?.first {
                // Update the place name with the first placemark address
                self.placeName = placemark.compactAddress ?? "Place name not available"
            }
        }
    }

}



extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
}
