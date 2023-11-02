//
//  NewFile.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 11/2/23.
//
//
//import Foundation




//IGNORE
//trying to implement cloud storage for next assignment










//func saveImageToCloudKit(image: UIImage, journalEntry: JournalEntry) {
//    // Converting UIImage to Data
//    guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
//    
//    // Saving image data to a temporary file to create a Cloud kit Asset
//    let temporaryDirectory = FileManager.default.temporaryDirectory
//    let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
//    try? imageData.write(to: fileURL)
//    
//    // Creating a Cloud Kit Asset from the file URL
//    let photoAsset = CKAsset(fileURL: fileURL)
//    
//    // Creating a Cloud Kit Record for the new journal entry
//    let journalRecord = CKRecord(recordType: "JournalEntry")
//    journalRecord["title"] = journalEntry.title
//    journalRecord["description"] = journalEntry.description
//    journalRecord["date"] = journalEntry.date
//    journalRecord["weather"] = journalEntry.weather
//    journalRecord["photo"] = photoAsset // CKAsset
//    
//    // Saving the record to the public database
//    let publicDatabase = CKContainer.default().publicCloudDatabase
//    publicDatabase.save(journalRecord) { record, error in
//        if let error = error {
//            // error handling
//            print("Error saving record to CloudKit: \(error)")
//        } else {
//            // Removing the temporary file
//            try? FileManager.default.removeItem(at: fileURL)
//            
//            // Doing something with the saved record, if needed
//            print("Successfully saved record to CloudKit")
//        }
//    }
//}
//
//func fetchJournalEntriesFromCloudKit(completion: @escaping ([JournalEntry]) -> Void) {
//    let query = CKQuery(recordType: "JournalEntry", predicate: NSPredicate(value: true))
//    let operation = CKQueryOperation(query: query)
//
//    var journalEntries = [JournalEntry]()
//
//    operation.recordMatchedBlock = { (recordID, result) in
//        switch result {
//        case .success(let record):
//            let title = record["title"] as? String ?? ""
//            let description = record["description"] as? String ?? ""
//            let date = record["date"] as? Date ?? Date()
//            let weather = record["weather"] as? String
//            var photos: [UIImage]? = nil
//            if let photoAsset = record["photo"] as? CKAsset, let fileURL = photoAsset.fileURL, let imageData = try? Data(contentsOf: fileURL) {
//                photos = [UIImage(data: imageData)].compactMap { $0 }
//            }
//            let journalEntry = JournalEntry(title: title, description: description, date: date, weather: weather, photos: photos, recordID: record.recordID)
//            journalEntries.append(journalEntry)
//        case .failure(let error):
//            print("Error fetching record with ID \(recordID): \(error)")
//        }
//    }
//
//    operation.queryResultBlock = { result in
//        DispatchQueue.main.async {
//            switch result {
//            case .success(let cursor):
//                if cursor != nil {
//                    // Handle the cursor if you need to perform additional fetches
//                }
//                completion(journalEntries)
//            case .failure(let error):
//                print("Error completing the query: \(error)")
//                completion([])
//            }
//        }
//    }
//
//    let publicDatabase = CKContainer.default().publicCloudDatabase
//    publicDatabase.add(operation)
//}
//
