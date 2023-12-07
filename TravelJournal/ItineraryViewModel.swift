//
//  ItineraryViewModel.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 12/8/23.
//
import Foundation
import Combine
import SwiftUI

class ItineraryViewModel: ObservableObject {
    @Published var items: [ItineraryItem] = []

    init() {
        loadFromPersistentStore()
    }

    func addItem(_ item: ItineraryItem) {
        items.append(item)
        saveToPersistentStore()
    }

    func removeItem(at index: IndexSet) {
        items.remove(atOffsets: index)
        saveToPersistentStore()
    }

    func updateItem(_ item: ItineraryItem, at index: Int) {
        items[index] = item
        saveToPersistentStore()
    }

    private func saveToPersistentStore() {
        do {
            let data = try JSONEncoder().encode(items)
            let fileURL = getDocumentsDirectory().appendingPathComponent("itineraryItems.json")
            try data.write(to: fileURL, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Error saving itinerary items: \(error)")
        }
    }

    private func loadFromPersistentStore() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("itineraryItems.json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                items = try JSONDecoder().decode([ItineraryItem].self, from: data)
            } catch {
                print("Error loading itinerary items: \(error)")
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
