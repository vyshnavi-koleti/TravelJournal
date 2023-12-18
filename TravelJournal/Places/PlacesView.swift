
import SwiftUI
import Combine
import PhotosUI
import CoreLocation
import CoreLocationUI
import MapKit
import Foundation



struct PlacesView: View {
    @EnvironmentObject var localSearchService: LocalSearchService
    @State private var search: String = ""
    
    var body: some View {
        VStack {
            
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    localSearchService.search(query: search)
                }.padding()
            
            if localSearchService.landmarks.isEmpty {
                Text("Awesome places awaits you!")
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray, lineWidth: 2)
                    )
            } else {
                LandmarkListView()
            }
            
            Map(coordinateRegion: $localSearchService.region, showsUserLocation: true, annotationItems: localSearchService.landmarks) { landmark in
                
                MapAnnotation(coordinate: landmark.coordinate) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(localSearchService.landmark == landmark ? .purple: .red)
                        .scaleEffect(localSearchService.landmark == landmark ? 2: 1)
                }
                
            }
            
            Spacer()
        }
    }
}




//
//import SwiftUI
//import MapKit
//
//struct MapView: UIViewRepresentable {
//    @Binding var region: MKCoordinateRegion
//    var landmarks: [Landmark]
//    var onSelectLandmark: (Landmark) -> Void
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(region, animated: true)
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        updateAnnotations(from: uiView)
//    }
//
//    private func updateAnnotations(from mapView: MKMapView) {
//        mapView.removeAnnotations(mapView.annotations)
//        
//        for landmark in landmarks {
//            let annotation = MKPointAnnotation()
//            annotation.title = landmark.name
//            annotation.coordinate = landmark.coordinate
//            mapView.addAnnotation(annotation)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: MapView
//
//        init(_ parent: MapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            let identifier = "Landmark"
//            var view: MKMarkerAnnotationView
//
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
//                dequeuedView.annotation = annotation
//                view = dequeuedView
//            } else {
//                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            }
//
//            view.markerTintColor = annotation.title == parent.selectedLandmark?.name ? .purple : .red
//            return view
//        }
//
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            if let annotationTitle = view.annotation?.title, let landmark = parent.landmarks.first(where: { $0.name == annotationTitle }) {
//                parent.onSelectLandmark(landmark)
//            }
//        }
//    }
//}
//
//
//struct PlacesView: View {
//    @EnvironmentObject var localSearchService: LocalSearchService
//    @State private var search: String = ""
//
//    var body: some View {
//        VStack {
//            TextField("Search", text: $search)
//                .textFieldStyle(.roundedBorder)
//                .onSubmit {
//                    localSearchService.search(query: search)
//                }.padding()
//
//            if localSearchService.landmarks.isEmpty {
//                Text("Awesome places awaits you!")
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(.gray, lineWidth: 2)
//                    )
//            } else {
//                LandmarkListView(onSelectLandmark: { landmark in
//                    localSearchService.region = MKCoordinateRegion(center: landmark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
//                })
//            }
//
//            MapView(region: $localSearchService.region, landmarks: localSearchService.landmarks, onSelectLandmark: { landmark in
//                localSearchService.region = MKCoordinateRegion(center: landmark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
//            })
//        }
//    }
//}
//
//
