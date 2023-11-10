//
//  ContentView.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 10/26/23.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit
//import CloudKit



struct ContentView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntryView = false
    
    var body: some View {
        NavigationView {
            List(viewModel.journalEntries) { entry in
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
                NewJournalEntryView(viewModel: viewModel, journalEntries: $viewModel.journalEntries, saveAction: viewModel.saveJournalEntries)
            }
        }
        .onAppear {
            viewModel.loadJournalEntries()
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
