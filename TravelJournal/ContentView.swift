//
//  ContentView.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 10/26/23.
//



import SwiftUI
import Combine
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntryView = false
    @State private var selectedTab = 0  // Default tab index
    @StateObject private var localSearchService = LocalSearchService()

    var body: some View {
        TabView(selection: $selectedTab) {
            // Travel Journals Tab
            NavigationView {
                ZStack {
                    Image("homepage_image2").scaledToFill()
                    List(viewModel.journalEntries) { entry in
                        NavigationLink(destination: JournalDetailView(entry: .constant(entry), viewModel: viewModel, onSave: { updatedEntry in
                            viewModel.updateJournalEntry(updatedEntry)
                        })) {
                            Text(entry.title)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                // Delete action
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .navigationBarTitle("Travel Journals", displayMode: .inline)
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
                Label("Journals", systemImage: "book.fill")
            }
            .tag(0)

            // Places Tab
            NavigationView {
                PlacesView()
                    .environmentObject(localSearchService)
                    .navigationBarTitle("Explore", displayMode: .inline)
            }
            .tabItem {
                Label("Explore", systemImage: "mappin.and.ellipse")
            }
            .tag(1)

            // Itinerary Tab
            NavigationView {
                ItineraryListView()
                    .navigationBarTitle("Itinerary", displayMode: .inline)
            }
            .tabItem {
                Label("Itinerary", systemImage: "map.fill")
            }
            .tag(2)

            // Expense Tracker
            NavigationView {
                ExpenseTrackerView()
                    .navigationBarTitle("Expenses", displayMode: .inline)
            }
            .tabItem {
                Label("Expenses", systemImage: "dollarsign.circle")
            }
            .tag(3)
        }
        .accentColor(Color(hex: "#355D48"))
    }
}







#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
