import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit
import WeatherKit


struct JournalDetailView: View {
    @Binding var entry: JournalEntry
    var viewModel: JournalViewModel
    @State private var showingEditView = false
    @State private var editableEntry: JournalEntry
    @State private var selectedPhotosPickerItems: [PhotosPickerItem] = []
    @State private var placeName: String = ""
    @State private var isGeocoding = false


    
    var onSave: (JournalEntry) -> Void
    
    init(entry: Binding<JournalEntry>, viewModel: JournalViewModel, onSave: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self.viewModel = viewModel
        self.onSave = onSave
        let initialEntry = entry.wrappedValue
//        initialEntry.weather = initialEntry.weather ?? "Default Weather Value"
        self._editableEntry = State(initialValue: initialEntry)
        if editableEntry.photos == nil {
            editableEntry.photos = []
        }
        print("Initial place name: \(initialEntry.placeName ?? "nil")")
//        print("Initial description: \(initialEntry.description)") // Debugging line
    }


    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                if showingEditView {
                    
                    // Editable title
                    TextField("Title", text: $editableEntry.title)
                        .placeholder(editableEntry.title.isEmpty) {
                                Text("Enter Title").foregroundColor(.gray)
                            }
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else {
                    // Display title
                    Text(entry.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                

                
                // Date
                if showingEditView {
                    DatePicker("Date", selection: $editableEntry.date, displayedComponents: .date)
                        .font(.subheadline)
                } else {
                    Text(entry.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                

                // Location
                if showingEditView {
                    TextField("Latitude", value: $editableEntry.latitude, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .placeholder(editableEntry.latitude == nil) {
                            Text("Enter Latitude").foregroundColor(.gray)
                        }
                    TextField("Longitude", value: $editableEntry.longitude, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .placeholder(editableEntry.longitude == nil) {
                            Text("Enter Longitude").foregroundColor(.gray)
                        }
                } else if let latitude = entry.latitude, let longitude = entry.longitude {
                    Text("Location: \(latitude), \(longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Location: Not Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Place Name
                if showingEditView {
                    TextField("Place Name", text: Binding<String>(
                        get: { editableEntry.placeName ?? "" },
                        set: {
                            editableEntry.placeName = $0.isEmpty ? nil : $0
                            if let placeName = editableEntry.placeName {
                                viewModel.geocodeAddressString(placeName) { newCoordinates in
                                    editableEntry.latitude = newCoordinates.latitude
                                    editableEntry.longitude = newCoordinates.longitude
                                    
                                    viewModel.fetchWeatherData(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude) { weatherDescription in
                                        self.editableEntry.weather = weatherDescription
                                    }
                                }
                            }
                        }
                    ))
                    .placeholder(editableEntry.placeName?.isEmpty ?? true) {
                        Text("Enter Place Name").foregroundColor(.gray)
                    }
                    .font(.subheadline)
                } else {
                    Text("Place Name: \(entry.placeName ?? "Not Available")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
//                if showingEditView {
//                    TextField("Place Name", text: $editableEntry.placeName.nilCoalescingBinding)
//                        .font(.subheadline)
//                        .onChange(of: editableEntry.placeName) { newValue in
//                            viewModel.geocodeAddressString(newValue) { newCoordinates in
//                                editableEntry.latitude = newCoordinates.latitude
//                                editableEntry.longitude = newCoordinates.longitude
//                                viewModel.fetchWeatherData(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude) { weatherDescription in
//                                    editableEntry.weather = weatherDescription
//                                }
//                            }
//                        }
//                    
//                } else {
//                    Text("Place Name: \(entry.placeName ?? "Not Available")")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }



                
                
                // Weather
                if showingEditView {
                    TextField("Weather", text: $editableEntry.weather)
                        .font(.subheadline)
                } else {
                    Text("Weather: \(entry.weather)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }


                
                // Description
                if showingEditView {
                    TextEditor(text: $editableEntry.description)
                        .font(.body) 
                        .frame(minHeight: 100)
                        .placeholder(editableEntry.description.isEmpty) {
                                Text("Enter a description").foregroundColor(.gray)
                            }
                } else {
                    Text(entry.description)
                        .font(.body)
                }

                // Photos
                if showingEditView {
                    PhotosPicker(
                        "Select images",
                        selection: $selectedPhotosPickerItems,
                        matching: .images
                    )
                    .onChange(of: selectedPhotosPickerItems) { newItems, _ in
                        Task {
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    editableEntry.photos?.append(data)
                                }
                            }
                        }
                    }
                    
                    // Display existing photos with a delete option
                    // Display existing photos with a delete option
                    if let photos = editableEntry.photos {
                        ForEach(photos.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: photos[index]) {
                                HStack {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        editableEntry.photos?.remove(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    // Display photos in read-only mode
                    if let photosData = entry.photos {
                        ForEach(photosData.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: photosData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Journal Entry", displayMode: .inline)
        .navigationBarItems(trailing: Button(showingEditView ? "Save" : "Edit") {
            if showingEditView {
                // Save changes
//                viewModel.updateJournalEntry(entry)
//                entry = editableEntry
                onSave(editableEntry)
            }
            showingEditView.toggle()
        })

    }
}

extension View {
    @ViewBuilder
    func placeholder<Content: View>(_ show: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: @escaping () -> Content) -> some View {
        ZStack(alignment: alignment) {
            if show {
                placeholder()
            }
            self
        }
    }
}


extension Optional where Wrapped == String {
    func nilCoalescingBinding(update: @escaping (String?) -> Void) -> Binding<String> {
        Binding<String>(
            get: { self ?? "" },
            set: { newValue in
                update(newValue.isEmpty ? nil : newValue)
            }
        )
    }
}
