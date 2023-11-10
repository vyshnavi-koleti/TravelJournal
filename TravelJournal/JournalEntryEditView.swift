//import Foundation
//import Combine
//import SwiftUI
//import PhotosUI
//import CoreLocation
//import CoreLocationUI
//import MapKit
//
//struct JournalEntryEditView: View {
//    @Binding var journalEntry: JournalEntry
//    var saveAction: () -> Void
//    
//    @State private var isPhotoPickerPresented = false
//    @State private var newPhotos: [Data] = []
//    @State private var selectedItems: [PhotosPickerItem] = []
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Details")) {
//                    TextField("Title", text: $journalEntry.title)
//                    TextField("Description", text: $journalEntry.description)
//                    DatePicker("Date", selection: $journalEntry.date, displayedComponents: .date)
//                }
//                
//                Section(header: Text("Location")) {
//                    TextField("Latitude", value: $journalEntry.latitude, formatter: NumberFormatter())
//                    TextField("Longitude", value: $journalEntry.longitude, formatter: NumberFormatter())
//                    TextField("Place Name", text: $journalEntry.placeName.nilCoalescingBinding())
//                }
//                
//                Section(header: Text("Weather")) {
//                    TextField("Weather", text: $journalEntry.weather.nilCoalescingBinding())
//                }
//                
//                Section(header: Text("Photos")) {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(journalEntry.photos?.indices ?? [], id: \.self) { index in
//                                if let data = journalEntry.photos?[index], let image = UIImage(data: data) {
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(height: 100)
//                                        .onTapGesture {
//                                            journalEntry.photos?.remove(at: index)
//                                        }
//                                }
//                            }
//                        }
//                    }
//                    
//                    Button("Add Photo") {
//                        isPhotoPickerPresented = true
//                    }
//                }
//            }
//            .navigationBarTitle("Edit Journal Entry", displayMode: .inline)
//            .navigationBarItems(trailing: Button("Save") {
//                if !newPhotos.isEmpty {
//                    journalEntry.photos = (journalEntry.photos ?? []) + newPhotos
//                }
//                saveAction()
//            })
//            .sheet(isPresented: $isPhotoPickerPresented) {
//                PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared())
//            }
//            .onChange(of: selectedItems) { newSelection in
//                Task {
//                    for item in newSelection {
//                        if let data = try? await item.loadTransferable(type: Data.self) {
//                            newPhotos.append(data)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//extension Binding where Value == String? {
//    init(_ source: Binding<Value>, replacingNilWith defaultValue: String) {
//        self.init(
//            get: { source.wrappedValue ?? defaultValue },
//            set: { newValue in source.wrappedValue = newValue.isEmpty ? nil : newValue }
//        )
//    }
//}
//
//extension Optional where Wrapped == String {
//    func nilCoalescingBinding() -> Binding<String> {
//        Binding<String>(
//            get: { self ?? "" },
//            set: { newValue in
//                self = newValue.isEmpty ? nil : newValue
//            }
//        )
//    }
//}
//
//
//            
////            .sheet(isPresented: $isPhotoPickerPresented) {
////                PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) { result in
////                    switch result {
////                    case .success(let response):
////                        if let data = try? response.itemProvider.loadTransferable(type: Data.self) {
////                            newPhotos.append(data)
////                        }
////                    case .failure(let error):
////                        // Handle errors
////                        print("Error selecting photo: \(error.localizedDescription)")
////                    }
////                }
////            }
////
////        }
////    }
////}
////    
////
