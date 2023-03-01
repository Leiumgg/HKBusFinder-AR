//
//  MapView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import SwiftUI
import MapKit

struct HomeMapView: UIViewRepresentable {
    @EnvironmentObject var mapData: HomeMapViewModel
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = mapData.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HomeMapView
        init(parent: HomeMapView) {
            self.parent = parent
        }
        
        // Render the route
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "stop")
            switch annotation.subtitle {
                case "Destination":
                    annotationView.markerTintColor = .systemRed
                    annotationView.displayPriority = .required
                default:
                    annotationView.markerTintColor = .systemOrange
            }
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                withAnimation {
                    parent.mapData.selectedPin = annotation
                }
            }
        }
    }
}
