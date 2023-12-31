import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit


enum AlertType {
    case missingInfo
    case emptyPlaceName
    case none
}

struct NewJournalEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Binding var journalEntries: [JournalEntry]
    var saveAction: () -> Void
    
    @State private var showAlert = false
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var weather = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uiImages = [Data]()
    @State private var alertType: AlertType = .none
    
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                titleField
                descriptionField
                locationSection
                weatherField
                datePickerSection
                photosPickerSection
            }
            .navigationBarTitle("New Entry")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .accentColor(Color(hex: "#355D48"))
        .alert(isPresented: Binding<Bool>(
            get: { alertType != .none },
            set: { if !$0 { alertType = .none } }
        )) {
            switch alertType {
            case .missingInfo:
                return Alert(
                    title: Text("Missing Information"),
                    message: Text("Both title and description are required to save the journal entry."),
                    dismissButton: .default(Text("OK"))
                )
            case .emptyPlaceName:
                return Alert(
                    title: Text("Missing Place Name"),
                    message: Text("Please enter a place name to update the location and weather."),
                    dismissButton: .default(Text("OK"))
                )
            default:
                return Alert(title: Text("Error"), message: Text("An unexpected error occurred."))
            }
        }
        
        
    }
    
    private var titleField: some View {
        TextField("Title", text: $title)
    }
    
    private var descriptionField: some View {
        TextField("Description", text: $description)
    }
    
    
    
    
    private var locationSection: some View {
        Section(header: Text("Location")) {
            if let currentLocation = viewModel.currentLocation {
                Text("Current Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
            } else {
                Text("Current Location: Not Available")
            }
            TextField("Place Name", text: $viewModel.placeName)
            
            Button("Update Location and Weather") {
                if !viewModel.placeName.isEmpty {
                    viewModel.geocodeAddressString(viewModel.placeName) { newCoordinates in
                        viewModel.currentLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
                        viewModel.fetchWeatherData(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude) { fetchedWeather in
                            self.weather = fetchedWeather
                        }
                    }
                } else {
                    //                    print("Place name is empty")
                    alertType = .emptyPlaceName
                    
                }
            }
        }
    }
    
    
    
    
    private var weatherField: some View {
        TextField("Weather", text: $weather)
            .keyboardType(.default)
    }
    
    private var datePickerSection: some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
            .datePickerStyle(GraphicalDatePickerStyle())
    }
    
    private var photosPickerSection: some View {
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
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            if !title.isEmpty && !description.isEmpty {
                saveEntry()
            } else {
                alertType = .missingInfo
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = JournalEntry(
            title: title,
            description: description,
            date: selectedDate,
            weather: weather,
            photos: uiImages,
            latitude: viewModel.currentLocation?.coordinate.latitude,
            longitude: viewModel.currentLocation?.coordinate.longitude,
            placeName: viewModel.placeName
        )
        journalEntries.append(newEntry)
        saveAction()
        presentationMode.wrappedValue.dismiss()
    }
    
    
    
    private func updateWeather() {
        if let currentLocation = viewModel.currentLocation {
            viewModel.fetchWeatherData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude) { weatherDescription in
                self.weather = weatherDescription
            }
        }
    }
    
}

           
            
extension CLPlacemark {
     var compactAddress: String? {
         if let name = name {
             var result = name
             if let city = locality { result += ", \(city)" }
             if let country = country { result += ", \(country)" }
             return result
         }
         return nil
     }
 }

                                             
                                             
                                             
                                             
                                             
                                             
                                             
                                             
                                            
 






 
//
//
//            Form {
//
//                //                Location
//                Section(header: Text("Location")) {
//                    if let location = locationManager.location {
//                        Text("Current Location: \(selectedCoordinate.latitude), \(selectedCoordinate.longitude)")
//                        TextField("Place Name", text: $placeName)
//                    } else {
//                        Text("Location: Not Available")
//                    }
//                    Button("Choose on Map") {
//                        showingMap = true
//                    }
//                }
//                }
//
//            .navigationBarTitle("New Entry")
//            .navigationBarItems(leading: Button("Cancel") {
//                presentationMode.wrappedValue.dismiss()
//            }, trailing: Button("Save") {
//                saveEntry()
//            })
//            .sheet(isPresented: $showingMap) {
//                MapView(selectedCoordinate: $selectedCoordinate,
//                        initialLocation: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
//                        onConfirm: { newCoordinate in
//                            // Directly use newCoordinate which is a CLLocationCoordinate2D
//                            let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
//                            self.selectedCoordinate = newCoordinate // Update the selectedCoordinate
//                            self.locationManager.location = newLocation
//                    NewJournalEntryView.reverseGeocode(location: newLocation, completion: )
//                        })
//            }
//
//            
//            
//        }
//    }
//
