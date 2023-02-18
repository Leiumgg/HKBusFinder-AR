//
//  ARMapView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 19/2/2023.
//

import SwiftUI
import MapKit

struct ARMapView: UIViewRepresentable {
    @EnvironmentObject var ARData: ARMapViewModel
    
    func makeCoordinator() -> Coordinator {
        return ARMapView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = ARData.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        view.isZoomEnabled = false
        view.isScrollEnabled = false
        view.isRotateEnabled = false
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        // Render Overlay
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
