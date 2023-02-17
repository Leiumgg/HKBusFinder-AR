//
//  ToDestinationRouteMapView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 8/2/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct DirectionsMapView: UIViewRepresentable {
    @EnvironmentObject var mapData: DirectionsMapViewModel
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    
    func makeCoordinator() -> Coordinator {
        return DirectionsMapView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = mapData.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Add Pin When Region Set
        if mapData.hasSetRegion && !mapData.pinAdded {
            mapData.pinRouteStops(selectedRSInfo: matchRouteInfo.selectedRSInfo)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        // Render the route
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if overlay.title == "busRouteLine" {
                renderer.strokeColor = .systemRed
                renderer.lineWidth = 3
                return renderer
            }
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
            switch annotation.title {
                case "Get On":
                    annotationView.markerTintColor = .systemGreen
                case "Get Off":
                    annotationView.markerTintColor = .systemOrange
                case "Starting Point":
                    annotationView.markerTintColor = .clear
                    annotationView.image = UIImage(systemName: "record.circle")
                    annotationView.frame.size = CGSize(width: 30, height: 30)
                case "Destination":
                    annotationView.markerTintColor = .systemRed
                default:
                    annotationView.markerTintColor = .systemBlue
            }
            return annotationView
        }
    }
}
