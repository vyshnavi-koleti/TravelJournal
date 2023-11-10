import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit

struct JournalDetailView: View {
    @Binding var entry: JournalEntry
    var viewModel: JournalViewModel
    @State private var showingEditView = false
    @State private var editableEntry: JournalEntry
    
    var onSave: (JournalEntry) -> Void
    
    init(entry: Binding<JournalEntry>, viewModel: JournalViewModel, onSave: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self.viewModel = viewModel
        self.onSave = onSave
        var initialEntry = entry.wrappedValue
        initialEntry.weather = initialEntry.weather ?? ""
        self._editableEntry = State(initialValue: initialEntry)
        print("Initial description: \(initialEntry.description)") // Debugging line
    }


    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                if showingEditView {
                    // Editable title
                    TextField("Title", text: $editableEntry.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else {
                    // Display title
                    Text(entry.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                //                Text(entry.title)
                //                    .font(.largeTitle)
                //                    .fontWeight(.bold)
                
                // Date
                if showingEditView {
                    DatePicker("Date", selection: $editableEntry.date, displayedComponents: .date)
                        .font(.subheadline)
                } else {
                    Text(entry.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                
                
                //                Text(entry.date, style: .date)
                //                    .font(.subheadline)
                //                    .foregroundColor(.gray)
                
                // Location
                
                if showingEditView {
                    TextField("Latitude", value: $editableEntry.latitude, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                    TextField("Longitude", value: $editableEntry.longitude, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                } else if let latitude = entry.latitude, let longitude = entry.longitude {
                    Text("Location: \(latitude), \(longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Location: Not Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                
                //                if let latitude = entry.latitude, let longitude = entry.longitude {
                //                    Text("Location: \(latitude), \(longitude)")
                //                        .font(.subheadline)
                //                        .foregroundColor(.gray)
                //                } else {
                //                    Text("Location: Not Available")
                //                        .font(.subheadline)
                //                        .foregroundColor(.gray)
                //                }
                
                
                // Weather
                
                // Weather
                if showingEditView {
                    TextField("Weather", text: Binding<String>(
                        get: { editableEntry.weather ?? "" },
                        set: { editableEntry.weather = $0 }
                    ))
                } else {
                    Text("Weather: \(entry.weather ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                
                //                Text("Weather: \(entry.weather ?? "Unknown")")
                //                    .font(.subheadline)
                //                    .foregroundColor(.gray)
                
                // Description
                if showingEditView {
                    TextEditor(text: $editableEntry.description)
                        .font(.body) 
                        .frame(minHeight: 100)
                } else {
                    Text(entry.description)
                        .font(.body)
                }

                
                
                
                
                //                Text(entry.description)
                //                    .font(.body)
                
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
                //                Button("Edit") {
                //                            showingEditView = true
                //                        }
                //                .sheet(isPresented: $showingEditView) {
                //                    JournalEntryEditView(journalEntry: $entry,  saveAction: {
                //                        viewModel.updateJournalEntry(entry)
                //                        showingEditView = false
                //                    })
                //                }
                
                
                
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

//extension Optional where Wrapped == String {
//    mutating func nilCoalescingBinding() -> Binding<String> {
//        Binding<String>(
//            get: { self ?? "" },
//            set: { newValue in
//                self = newValue.isEmpty ? nil : newValue
//            }
//        )
//    }
//}
