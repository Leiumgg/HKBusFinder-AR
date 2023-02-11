//
//  RouteMapView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct ToStopRouteMapView: UIViewRepresentable {
    @EnvironmentObject var mapData: ToStopRouteMapViewModel
    
    func makeCoordinator() -> Coordinator {
        return ToStopRouteMapView.Coordinator()
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
        // Render the route
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        
        // Customize Pin
        func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            if annotation.title == "Go Here" {
                annotationView.markerTintColor = .systemRed
            }
            return annotationView
        }
    }
}

// Preview Example
// {"route":"103", "bound":"O", "service_type":"1", "seq":"33", "stop":"5D694E9F5A66F888"}
// {"stop":"5D694E9F5A66F888", "name_en":"HKU EAST GATE", "lat":"22.283931", "long":"114.139162"}
