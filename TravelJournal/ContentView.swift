//
//  ContentView.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 10/26/23.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct JournalEntry: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var weather: String?
    var photos: [Image]?
//    var location: CLLocation?

    
    // Initializing with default values
    init(title: String = "",
         description: String = "",
         date: Date = Date(),
         weather: String? = nil,
         photos: [Image]? = nil) 
    //         location: CLLocation? = nil,
    {
        self.title = title
        self.description = description
        self.date = date
        self.weather = weather
        self.photos = photos
//        self.location = location

    }
}


struct ContentView: View {
    @State private var journalEntries = [JournalEntry]()
    @State private var showingNewEntryView = false
    
    var body: some View {
        NavigationView {
            List(journalEntries) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    Text(entry.title)
                }
            }
            .navigationBarTitle("Travel Journal")
            .navigationBarItems(trailing: Button(action: {
                showingNewEntryView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingNewEntryView) {
                NewJournalEntryView(journalEntries: $journalEntries)
            }
        }
    }
}


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
                
                // Location
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
                if let photos = entry.photos {
                                    ForEach(0..<photos.count, id: \.self) { index in
                                                    photos[index]
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                }
                
                
//            Will add more UI elements as needed
                
            }
            .padding()
        }
        .navigationBarTitle("Journal Entry", displayMode: .inline)
    }
}



struct NewJournalEntryView: View {
    @Binding var journalEntries: [JournalEntry]
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var weather = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages = [Image]()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Weather", text: $weather)
                    .keyboardType(.default)
                
//                DatePicker for selecting date
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
//                Photo picker
                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
                            }
            .onChange(of: selectedItems){ newValue, _ in
                                Task {
                                    selectedImages.removeAll()
                                    for item in selectedItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            let image = Image(uiImage: uiImage)
                                            selectedImages.append(image)
                                        }
                                    }
                                }
                            }
              
            .navigationBarTitle("New Entry")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let newEntry = JournalEntry(title: title, description: description, date: selectedDate, weather: weather, photos: selectedImages)
                journalEntries.append(newEntry)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
