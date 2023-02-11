//
//  RouteMapViewModel.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI
import MapKit
import CoreLocation

class ToStopRouteMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var mapView = MKMapView()
    
    // Region
    @Published var region: MKCoordinateRegion!
    // Based on Location it will set up
    
    // Alert
    @Published var permissionDenied = false
    
    // Map Type
    @Published var mapType: MKMapType = .standard
    
    // Route Coordinates
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    // Closest Route Node
    @Published var closestRouteCoordinateIndex = 0
    
    // Destination Coordinate
    @Published var desCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Set jor Region Mei
    private var hasSetRegion = false
    
    private var hasRoute = [MKRoute]()
    
    // Focus Route
    func focusRoute() {
        if !hasRoute.isEmpty {
            self.mapView.setVisibleMapRect(hasRoute.last!.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35), animated: true)
        }
    }
    
    // Get Route and Direction
    func getDirection() {
        routeCoordinates = [CLLocationCoordinate2D]()
        closestRouteCoordinateIndex = 0
        
        let p1 = MKPlacemark(coordinate: self.region.center)
        if (desCoord.latitude == 0) && (desCoord.longitude == 0) {return}
        let p2 = MKPlacemark(coordinate: desCoord)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .walking
        
        self.mapView.removeOverlays(self.mapView.overlays)
        let directions = MKDirections(request: request)
        
        hasRoute = [MKRoute]()
        
        directions.calculate { response, error in
            guard let route = response?.routes.first else {return}
            self.hasRoute.append(route)
            self.routeCoordinates = route.polyline.coordinates
            for i in 0..<self.routeCoordinates.count {
                print("\(i): \(self.routeCoordinates[i])")
            }
            self.mapView.addOverlay(route.polyline)
        }
    }
    
    // Updating Map Type
    func updateMapType() {
        
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    // Focus Location
    func focusLocation() {
        guard let _ = region else { return }
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Checking Permissions
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
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Error
        print(error.localizedDescription)
    }
    
    // Getting User Region
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        //use location.altitude to get the sea level information for ar entity y-axis
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        // Smooth Animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        // Set mapView for once
        if !hasSetRegion {
            self.mapView.setRegion(region, animated: false)
            hasSetRegion = true
            
            let desAnnotation = MKPointAnnotation()
            desAnnotation.coordinate = desCoord
            desAnnotation.title = "Go Here"
            self.mapView.addAnnotation(desAnnotation)
        }
        
        self.getDirection()
        
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

