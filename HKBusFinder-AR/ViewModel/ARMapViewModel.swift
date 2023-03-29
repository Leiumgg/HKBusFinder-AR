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
    
    // Route Step Instruction
    @Published var routeInstruction = [String]()
    @Published var routeStepsCoords = [CLLocationCoordinate2D]()
    
    // Closest Route Node
    @Published var closestRouteCoordIndex = 0
    
    // Updated Walking ETA to Destination
    @Published var newDesETA = 0
    
    // Destination Coordinate
    @Published var desCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Set jor Region Mei
    @Published var hasSetRegion = false
    
    // User Heading
    @Published var userHeading: CLLocationDirection = 0

    // MapKit Calculate Walking ETA
    func MKWalkingETA(p1: MKPlacemark, p2: MKPlacemark, completion: @escaping (Int) -> Void){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            if error == nil {
                if let estimate = response {
                    let mkTransitEta = Int((estimate.expectedTravelTime/60).rounded(.up))
                    completion(mkTransitEta)
                }
            }
        }
    }
    
    // Get Direction: User Location to Source Bus Stop
    func getDirection(Source: CLLocationCoordinate2D, Destination: CLLocationCoordinate2D) {
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        routeCoordinates = [CLLocationCoordinate2D]()
        closestRouteCoordIndex = 0
        
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
            
            self.routeCoordinates = route.steps.map {$0.polyline.coordinate}
            self.mapView.addOverlay(route.polyline)
            
            self.routeInstruction = route.steps.map {$0.instructions}
        }
        
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
    
    // Map Camera Setting (Heading)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.userHeading = newHeading.trueHeading
        let camera = mapView.camera
        camera.heading = newHeading.trueHeading
        camera.pitch = 45
        mapView.setCamera(camera, animated: true)
    }
    
    // User Location Update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        //use location.altitude to get the sea level information for ar entity y-axis
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        
        // Center User Location Viewing Region
        self.mapView.setRegion(self.region, animated: false)
        
        // Run Once Only
        if !hasSetRegion {
            hasSetRegion = true
            MKWalkingETA(p1: MKPlacemark(coordinate: region.center), p2: MKPlacemark(coordinate: desCoord)) { desETA in
                self.newDesETA = desETA
            }
        }
        
        // Map Camera Setting (Coordinate)
        let camera = mapView.camera
        camera.centerCoordinate = location.coordinate
        camera.pitch = 45
        camera.heading = self.userHeading
        mapView.setCamera(camera, animated: true)
        
        // Find closest route node
            //change this later for better finding the closest node
        if !routeCoordinates.isEmpty {
            if closestRouteCoordIndex < routeCoordinates.count-1 {
                let curLoc = CLLocation(latitude: routeCoordinates[closestRouteCoordIndex].latitude, longitude: routeCoordinates[closestRouteCoordIndex].longitude)
                let nextLoc = CLLocation(latitude: routeCoordinates[closestRouteCoordIndex+1].latitude, longitude: routeCoordinates[closestRouteCoordIndex+1].longitude)
                if nextLoc.distance(from: location) < curLoc.distance(from: location){
                    closestRouteCoordIndex += 1
                    MKWalkingETA(p1: MKPlacemark(coordinate: region.center), p2: MKPlacemark(coordinate: desCoord)) { desETA in
                        self.newDesETA = desETA
                    }
                }
            }
        }
        
    }
    
}

