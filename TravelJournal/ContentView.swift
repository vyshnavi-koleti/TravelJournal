//
//  ContentView.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 10/26/23.
//

import SwiftUI
import PhotosUI
import CoreLocation
//import CloudKit


struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var weather: String?
    var photos: [Data]?

//    var recordID: CKRecord.ID?
//    var location: CLLocation?

    
    // Initializing with default values
    init(title: String = "",
         description: String = "",
         date: Date = Date(),
         weather: String? = nil,
         photos: [Data]? = nil)
//        recordID: CKRecord.ID? = nil)
    //         location: CLLocation? = nil,
    {
        self.title = title
        self.description = description
        self.date = date
        self.weather = weather
        self.photos = photos
//        self.recordID = recordID
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
                NewJournalEntryView(journalEntries: $journalEntries, saveAction: saveJournalEntries)
            }
        }
        .onAppear {
            if !FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("journalEntries.json").path) {
                saveJournalEntries() // This will create an empty file on first launch
            }
            loadJournalEntries()
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
    
//   function to get the documents directory
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
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
                if let photosData = entry.photos {
                                    ForEach(photosData.indices, id: \.self) { index in
                                        if let uiImage = UIImage(data: photosData[index]) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                        }
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
    var saveAction: () -> Void
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var weather = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uiImages = [Data]()
//    @State private var selectedImages = [Image]()
//    @State private var uiImages = [UIImage]()
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

            .navigationBarTitle("New Entry")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let newEntry = JournalEntry(title: title, description: description, date: selectedDate, weather: weather, photos: uiImages)
                journalEntries.append(newEntry)
                saveAction() // Call the passed-in save function
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
