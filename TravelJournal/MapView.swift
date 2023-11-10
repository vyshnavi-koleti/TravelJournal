import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit



struct MapView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Environment(\.presentationMode) var presentationMode
    var onConfirm: (CLLocationCoordinate2D) -> Void

    // Define the state for the map region
    @State private var region: MKCoordinateRegion
    private var initialLocation: CLLocationCoordinate2D

    init(selectedCoordinate: Binding<CLLocationCoordinate2D>, initialLocation: CLLocationCoordinate2D, onConfirm: @escaping (CLLocationCoordinate2D) -> Void) {
            self._selectedCoordinate = selectedCoordinate
            self.onConfirm = onConfirm
            self.initialLocation = initialLocation
            self._region = State(initialValue: MKCoordinateRegion(center: initialLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
    
    
    var body: some View {
        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: <#_#>) {_ in 
            MapAnnotation(coordinate: selectedCoordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            if selectedCoordinate.latitude == 0 && selectedCoordinate.longitude == 0 {
                region.center = initialLocation
            } else {
                region.center = selectedCoordinate
            }
        }
        Button("Confirm Location") {
            onConfirm(region.center)
            presentationMode.wrappedValue.dismiss()
        }
        .padding()
    }
}





struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

//struct IdentifiableCoordinate: Identifiable {
//    let id = UUID()
//    var coordinate: CLLocationCoordinate2D
//}




//struct MapView: View {
//    @Binding var selectedCoordinate: CLLocationCoordinate2D
//    var initialLocation: CLLocationCoordinate2D
//    @Environment(\.presentationMode) var presentationMode
//    var onConfirm: (CLLocation) -> Void
//
//    // Define the state for the map region
//    @State private var region = MKCoordinateRegion()
//
//    var body: some View {
//        Map(coordinateRegion: $region, annotationItems: [AnnotationItem(coordinate: selectedCoordinate)]) { item in
//            MapMarker(coordinate: item.coordinate, tint: .red)
//        }
//        .onAppear {
//            // Set the region to the initial location or the selected coordinate
//            region = MKCoordinateRegion(center: selectedCoordinate.latitude == 0 && selectedCoordinate.longitude == 0 ? initialLocation : selectedCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//        }
//        Button("Confirm Location") {
//            let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
//            onConfirm(location)
//            selectedCoordinate = location.coordinate // Updating the selectedCoordinate
//            presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
//
