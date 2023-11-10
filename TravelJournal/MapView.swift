import Foundation
import Combine
import SwiftUI
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit



extension CLLocationCoordinate2D{
    static let startPosition = CLLocationCoordinate2D(latitude: 40.0150, longitude: -105.2705)
    
}



struct MapView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    var initialLocation: CLLocationCoordinate2D
    @Environment(\.presentationMode) var presentationMode
    var onConfirm: (CLLocationCoordinate2D) -> Void
    @State private var initialRegion: MKCoordinateRegion
    @State private var position: MapCameraPosition = .automatic

    
    

    // Create an array of annotation items
    private var annotationItems: [MapAnnotationItem] {
        [MapAnnotationItem(coordinate: selectedCoordinate)]
    }

    init(selectedCoordinate: Binding<CLLocationCoordinate2D>, initialLocation: CLLocationCoordinate2D, onConfirm: @escaping (CLLocationCoordinate2D) -> Void) {
        self._selectedCoordinate = selectedCoordinate
        self.initialLocation = initialLocation
        self.onConfirm = onConfirm
        self._initialRegion = State(initialValue: MKCoordinateRegion(center: initialLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
//        Map(coordinateRegion: $initialRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: annotationItems) { item in
//            MapAnnotation(coordinate: item.coordinate) {
//                Image(systemName: "mappin.circle.fill")
//                    .font(.title)
//                    .foregroundColor(.red)
//            }
//        }
        Map(initialPosition: position) {
            Marker("Test", coordinate: .startPosition)
        }
        .mapStyle(.hybrid)
//        Map(initialPosition: $initialRegion ){
//            
//        }
        .onAppear {
            if selectedCoordinate.latitude == 0 && selectedCoordinate.longitude == 0 {
                initialRegion.center = initialLocation
            } else {
                initialRegion.center = selectedCoordinate
            }
        }
        Button("Confirm Location") {
            onConfirm(initialRegion.center)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
