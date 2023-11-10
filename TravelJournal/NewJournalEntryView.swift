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
    var saveAction: () -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var weather = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uiImages = [Data]()
    
    @State private var placeName: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: JournalViewModel, journalEntries: Binding<[JournalEntry]>, saveAction: @escaping () -> Void) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self._journalEntries = journalEntries
        self.saveAction = saveAction
        self._placeName = State(initialValue: viewModel.placeName)
        
    }
    
    static func reverseGeocode(location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                completion("Unable to find place name")
            } else if let placemark = placemarks?.first {
                completion(placemark.compactAddress ?? "Place name not available")
            }
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            Form {
                titleField
                descriptionField
                weatherField
                locationSection
                datePickerSection
                photosPickerSection
            }
            .navigationBarTitle("New Entry")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .accentColor(Color(hex: "#355D48")) // Apply the primary color here
    }
    
    private var titleField: some View {
        TextField("Title", text: $title)
            
    }
    
    private var descriptionField: some View {
        TextField("Description", text: $description)
            
    }
    
    private var weatherField: some View {
        TextField("Weather", text: $weather)
            .keyboardType(.default)
            
    }
    
    private var locationSection: some View {
        Section(header: Text("Location")) {
            Text("Current Location: \(viewModel.selectedCoordinate.latitude), \(viewModel.selectedCoordinate.longitude)")
            TextField("Place Name", text: $placeName)
                .onChange(of: placeName) { newValue, _ in
                    viewModel.geocodeAddressString(newValue)
                }
        }
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
            saveEntry()
        }
    }
    
    func saveEntry() {
        let newEntry = JournalEntry(
            title: title,
            description: description,
            date: selectedDate,
            weather: weather,
            photos: uiImages,
            location: viewModel.currentLocation
        )
        journalEntries.append(newEntry)
        saveAction()
        presentationMode.wrappedValue.dismiss()
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

                                             
                                             
                                             
                                             
                                             
                                             
                                             
                                             
                                            
    
    
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Title", text: $title)
//                    .background(Color(hex: "#EBBB86"),
//                TextField("Description", text: $description)
//                        .background(Color(hex: "#EBBB86"),
//                TextField("Weather", text: $weather)
//                    .keyboardType(.default)
//                    .background(Color(hex: "#EBBB86"),
//                
//                Section(header: Text("Location")) {
//                                    Text("Current Location: \(viewModel.selectedCoordinate.latitude), \(viewModel.selectedCoordinate.longitude)")
//                                    TextField("Place Name", text: $placeName)
//                                        .onChange(of: placeName) { newValue , _ in
//                                            viewModel.geocodeAddressString(newValue)
//                                        }
//                    }.background(Color(hex: "#EBBB86"),
//                
//                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
//                    .datePickerStyle(GraphicalDatePickerStyle())
//                    .background(Color(hex: "#EBBB86")),
//                
//                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
//                    .onChange(of: selectedItems) { newValue, _ in
//                        Task {
//                            uiImages.removeAll()
//                            for item in selectedItems {
//                                if let data = try? await item.loadTransferable(type: Data.self) {
//                                    uiImages.append(data)
//                                }
//                            }
//                        }
//                    }
//            }
//            .navigationBarTitle("New Entry")
//            .navigationBarItems(leading: Button("Cancel") {
//                presentationMode.wrappedValue.dismiss()
//            }, trailing: Button("Save") {
//                saveEntry()
//            })
//        }
//        .accentColor(Color(hex: "#355D48"))
//    }
//
//    func saveEntry() {
//            let newEntry = JournalEntry(
//                title: title,
//                description: description,
//                date: selectedDate,
//                weather: weather,
//                photos: uiImages,
//                location: viewModel.currentLocation
//            )
//            journalEntries.append(newEntry)
//            saveAction()
//            presentationMode.wrappedValue.dismiss()
//        }
//}











 
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
//    
//    
//    func saveEntry() {
//        let newEntry = JournalEntry(
//            title: title,
//            description: description,
//            date: selectedDate,
//            weather: weather,
//            photos: uiImages,
//            location: locationManager.location
//        )
//        journalEntries.append(newEntry)
//        saveAction()
//        presentationMode.wrappedValue.dismiss()
//    }
//
//
//
//
