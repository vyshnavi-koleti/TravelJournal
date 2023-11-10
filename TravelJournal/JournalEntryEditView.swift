import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit



struct JournalEntryEditView: View {
    @Binding var journalEntry: JournalEntry
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var newImagesData: [Data] = []
    var saveAction: () -> Void

    var body: some View {
        Form {
            TextField("Title", text: $journalEntry.title)
            TextField("Description", text: $journalEntry.description)
            

            // Existing photos
            if let photosData = journalEntry.photos {
                ForEach(photosData.indices, id: \.self) { index in
                    if let uiImage = UIImage(data: photosData[index]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
            }

            // Photo picker for new photos
            PhotosPicker("Select images", selection: $selectedItems, matching: .images)
                .onChange(of: selectedItems) { newValue, _ in
                    Task {
                        newImagesData.removeAll()
                        for item in selectedItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                newImagesData.append(data)
                            }
                        }
                    }
                }

            Button("Save Changes") {
                // Append new images data to the existing photos
                if !newImagesData.isEmpty {
                    journalEntry.photos?.append(contentsOf: newImagesData)
                }
                saveAction()
            }
        }
    }
}
