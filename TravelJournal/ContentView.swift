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
import WeatherKit

//import CloudKit



struct ContentView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntryView = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Travel Journals Tab
            NavigationView {
                ZStack {
                    // Background image
                    Image("homepage_image2")
//                        .resizable()
                        .scaledToFill()
//                        .edgesIgnoringSafeArea(.all)

                    // List of journal entries
                    List {
                        ForEach(viewModel.journalEntries) { entry in
                            NavigationLink(destination: JournalDetailView(entry: .constant(entry), viewModel: viewModel, onSave: { updatedEntry in
                                viewModel.updateJournalEntry(updatedEntry)
                            })) {
                                Text(entry.title)
                            }
                            .swipeActions {
                                
                                // Delete action
                                Button(role: .destructive) {
                                    //delete
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Travel Journal", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    showingNewEntryView = true
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $showingNewEntryView) {
                    NewJournalEntryView(viewModel: viewModel, journalEntries: $viewModel.journalEntries, saveAction: viewModel.saveJournalEntries)
                }
            }
            .tabItem {
                Label("Travel Journals", systemImage: "book.fill")
            }
            .tag(0)
            
            
            ItineraryListView()
                    .tabItem {
                        Label("Itinerary", systemImage: "map.fill")
                    }
                    .tag(1)

            // Profile Tab - ti be replaced later with actual profile view later            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
            
        }
        .accentColor(Color(hex: "#355D48"))
    }
}

//?replace later

struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
}




#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

