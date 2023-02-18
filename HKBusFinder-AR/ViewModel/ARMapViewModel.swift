//
//  ARMapViewModel.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 18/2/2023.
//

import SwiftUI
import MapKit
import CoreLocation

class ARMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MKMapView
    @Published var mapView = MKMapView()
    
    // Region
    @Published var region: MKCoordinateRegion!
    
    // Check Permission
    @Published var permissionDenied = false
    
    // Route Coordinates
    @Published var routeCoordinates = [CLLocationCoordinate2D]()
    
    // Closest Route Node
    @Published var closestRouteCoordinateIndex = 0
    
    // Destination Coordinate
    @Published var desCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    

    // Get Direction: User Location to Source Bus Stop
    func getDirection(Source: CLLocationCoordinate2D, Destination: CLLocationCoordinate2D) {
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        routeCoordinates = [CLLocationCoordinate2D]()
        closestRouteCoordinateIndex = 0
        
        let p1 = MKPlacemark(coordinate: Source)
        let p2 = MKPlacemark(coordinate: Destination)
        
        desCoord = Destination
        
        let desPin = MKPointAnnotation()
        desPin.coordinate = Destination
        mapView.addAnnotation(desPin)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {return}
            
            self.routeCoordinates = route.polyline.coordinates
            self.mapView.addOverlay(route.polyline)
        }
        // DEBUG
        for i in 0..<routeCoordinates.count {print("\(i): \(routeCoordinates[i])")}
        
    }
    
    
    // Checking Permissions
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .denied:
                // Alert
                permissionDenied.toggle()
            case .notDetermined:
                // Requesting
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse:
                // If Permission Given
                manager.requestLocation()
                manager.startUpdatingLocation()
                manager.startUpdatingHeading()
            default:
                ()
        }
    }

    // Location Manager Stuff
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {print(error.localizedDescription)}
    
    // User Heading Update
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.camera.heading = newHeading.magneticHeading
        mapView.camera.pitch = 45
    }
    
    // User Location Update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        //use location.altitude to get the sea level information for ar entity y-axis
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        
        // Center User Location Viewing Region
        self.mapView.setRegion(self.region, animated: true)
        
        // Smooth Animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        
        // Find closest route node
            //change this later for better finding the closest node
        if !routeCoordinates.isEmpty {
            if closestRouteCoordinateIndex < routeCoordinates.count-1 {
                let curLoc = CLLocation(latitude: routeCoordinates[closestRouteCoordinateIndex].latitude, longitude: routeCoordinates[closestRouteCoordinateIndex].longitude)
                let nextLoc = CLLocation(latitude: routeCoordinates[closestRouteCoordinateIndex+1].latitude, longitude: routeCoordinates[closestRouteCoordinateIndex+1].longitude)
                if nextLoc.distance(from: location) < curLoc.distance(from: location){
                    closestRouteCoordinateIndex += 1
                }
            }
        }
        
    }
    
}

