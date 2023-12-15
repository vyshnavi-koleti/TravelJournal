//
//  ItineraryListView.swift
//  TravelJournal
//
//  Created by Vyshnavi Koleti on 12/8/23.
//

import Foundation
import Combine
import SwiftUI



struct ItineraryListView: View {
    @ObservedObject var viewModel = ItineraryViewModel()
    @State private var showingAddItemView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: ItineraryItemView(item: item)) {
                        Text(item.destination)
                    }
                }
                .onDelete(perform: viewModel.removeItem)
            }
            .navigationBarTitle("Itinerary")
            .navigationBarItems(trailing: Button("Add") {
                showingAddItemView = true
                
            })
            .sheet(isPresented: $showingAddItemView) {
                AddItineraryItemView(viewModel: viewModel)
            }
        }
    }
}

struct AddItineraryItemView: View {
    @ObservedObject var viewModel: ItineraryViewModel
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var activities: [Activity] = []
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Destination", text: $destination)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                
                Section(header: Text("Activities")) {
                    ForEach($activities.indices, id: \.self) { index in
                        VStack {
                            TextField("Activity Title", text: $activities[index].title)
                            TextField("Description", text: $activities[index].description)
                            DatePicker("Time", selection: $activities[index].time, displayedComponents: .hourAndMinute)
                        }
                    }
                    Button("Add Activity") {
                        activities.append(Activity(title: "", description: "", time: Date()))
                    }
                }

                TextField("Notes", text: $notes)
            }
            .navigationBarTitle("Add Itinerary Item")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                if validateInputs() {
                    let newItem = ItineraryItem(id: UUID(), destination: destination, startDate: startDate, endDate: endDate, activities: activities, notes: notes)
                    viewModel.addItem(newItem)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showingAlert = true
                }
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func validateInputs() -> Bool {
        // Ensure destination is not empty
        if destination.isEmpty {
            alertMessage = "Please enter a destination."
            return false
        }

        // Ensure there is at least one activity and none of the activity titles are empty
        if activities.contains(where: { $0.title.isEmpty }) {
            alertMessage = "Please enter a title for each activity."
            return false
        }

        return true
    }
}
