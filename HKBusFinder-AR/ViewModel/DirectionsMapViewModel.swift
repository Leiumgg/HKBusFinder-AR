//
//  ToDestinationRouteMapViewModel.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 8/2/2023.
//

import SwiftUI
import MapKit
import CoreLocation

class DirectionsMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MKMapView
    @Published var mapView = MKMapView()
    
    // Region
    @Published var region: MKCoordinateRegion!
    // Based on Location it will set up
    
    // User Heading
    @Published var userHeading: CLLocationDirection = 0
    
    // Alert
    @Published var permissionDenied = false
    
    // Map Type
    @Published var mapType: MKMapType = .standard
    
    // Walking Distance with Buffer
    @Published var walkingDistance = 310.0
    
    // Route Coordinates
    @Published var srcRouteCoordinates = [CLLocationCoordinate2D]()
    @Published var desRouteCoordinates = [CLLocationCoordinate2D]()
    
    // Key Annotation Coordinates
    @Published var busSrcCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var busDesCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var realSrcCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var realDesCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Is now walking to Real Destination or on Bus?
    @Published var isToSrcBS = false
    @Published var isOnBus = false
    @Published var isToRealDes = false
    
    // Store the 2 Walking Directions MKPolyline
    @Published var hasRoute = [MKRoute]()
    
    // Store Annotations
    @Published var keyAnnotations = [MKPointAnnotation]()
    
    // Set jor Region Mei
    @Published var hasSetRegion = false
    
    // RouteStopsMapView Add jor Pin and Route mei
    @Published var pinAdded = false
    
    // Going to Show What Route Next for focusRoute
    @Published var showToSrcRoute = true
    
    // Select Pin on Direction Map and Scroll View
    func selectPin(pinName: String) {
        var selectedPin = [MKAnnotation]()
        for i in mapView.annotations {
            if i.title == pinName {
                selectedPin.append(i)
                break
            }
        }
        mapView.selectAnnotation(selectedPin[0], animated: true)
        mapView.setRegion(MKCoordinateRegion(center: selectedPin[0].coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
    }
    
    // Add Annotation: Stops of Selected Route & Destination
    func pinRouteStops(selectedRSInfo: [seqStopInfo]) {
        // Add Annotation
        var busStopsPinList = [MKPointAnnotation]()
        for busStop in selectedRSInfo {
            let busStopPin = MKPointAnnotation()
            busStopPin.title = busStop.stopInfo.name_en
            if (Double(busStop.stopInfo.lat)! == busSrcCoord.latitude) && (Double(busStop.stopInfo.long)! == busSrcCoord.longitude) {
                busStopPin.subtitle = "Get On"
            } else if (Double(busStop.stopInfo.lat)! == busDesCoord.latitude) && (Double(busStop.stopInfo.long)! == busDesCoord.longitude) {
                busStopPin.subtitle = "Get Off"
            }
            busStopPin.coordinate = CLLocationCoordinate2D(latitude: Double(busStop.stopInfo.lat)!, longitude: Double(busStop.stopInfo.long)!)
            busStopsPinList.append(busStopPin)
        }
        self.mapView.addAnnotations(busStopsPinList)
        
        // Add Bus Route Line
        let busRouteLine = MKPolyline(coordinates: busStopsPinList.map {$0.coordinate}, count: busStopsPinList.count)
        busRouteLine.title = "busRouteLine"
        mapView.addOverlay(busRouteLine)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pinAdded = true
        }
    }
    
    // Initailize Pin and Dotted Line
    func initPinNDotLine() {
        self.mapView.setRegion(region, animated: false)
        realSrcCoord = region.center
        
        // Initialize MapView, Route and Annotation
        self.mapView.removeOverlays(self.mapView.overlays)
        hasRoute = [MKRoute]()
        self.mapView.removeAnnotations(self.mapView.annotations)
        keyAnnotations = [MKPointAnnotation]()
        
        // realSrcAnnotation
        let realSrcAnnotation = MKPointAnnotation()
        realSrcAnnotation.coordinate = realSrcCoord
        realSrcAnnotation.subtitle = "Starting Point"
        
        // realDesAnnotation
        let realDesAnnotation = MKPointAnnotation()
        realDesAnnotation.coordinate = realDesCoord
        realDesAnnotation.subtitle = "Destination"
        
        keyAnnotations = [realSrcAnnotation, realDesAnnotation]
        
        // mapView.annotations = [MyLocation] + keyAnnotation
        self.mapView.addAnnotations(keyAnnotations)
        
        getDirection(Source: realSrcCoord, Destination: busSrcCoord)
        getDirection(Source: busDesCoord, Destination: realDesCoord)
    }
    
    // Focus Route
    func focusRoute() {
        if hasRoute.isEmpty {return}
        
        if showToSrcRoute {
            self.mapView.setVisibleMapRect(hasRoute.first!.polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80) ,animated: true)
            showToSrcRoute.toggle()
        } else {
            self.mapView.setVisibleMapRect(hasRoute.last!.polyline.boundingMapRect,edgePadding: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80) ,animated: true)
            showToSrcRoute.toggle()
        }
    }
    
    // Change isToRealDes Boolean Status
    func checkTransitStatus() {
        if CLLocation(latitude: region.center.latitude, longitude: region.center.longitude).distance(from: CLLocation(latitude: realSrcCoord.latitude, longitude: realSrcCoord.longitude)) <= walkingDistance {
            isToSrcBS = true
            isToRealDes = false
            isOnBus = false
        } else if CLLocation(latitude: region.center.latitude, longitude: region.center.longitude).distance(from: CLLocation(latitude: realDesCoord.latitude, longitude: realDesCoord.longitude)) <= walkingDistance {
            isToSrcBS = false
            isToRealDes = true
            isOnBus = false
        } else {
            isToSrcBS = false
            isToRealDes = false
            isOnBus = true
        }
    }
    
    // Get Direction: User Location to Source Bus Stop
    func getDirection(Source: CLLocationCoordinate2D, Destination: CLLocationCoordinate2D) {
        
        srcRouteCoordinates = [CLLocationCoordinate2D]()
        desRouteCoordinates = [CLLocationCoordinate2D]()
        
        let p1 = MKPlacemark(coordinate: Source)
        let p2 = MKPlacemark(coordinate: Destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {return}
            
            if (Destination.latitude == self.busSrcCoord.latitude) && (Destination.longitude == self.busSrcCoord.longitude){
                self.srcRouteCoordinates = route.polyline.coordinates
                route.polyline.title = "To Bus Stop"
            } else {
                self.desRouteCoordinates = route.polyline.coordinates
                route.polyline.title = "To Destination"
            }
            self.hasRoute.append(route)
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
    
    // For Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Error
        print(error.localizedDescription)
    }
    
    // User Heading
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //
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
            hasSetRegion = true
            initPinNDotLine()
        }
        checkTransitStatus()
        print("isToSrcBS: \(isToSrcBS); isOnBus: \(isOnBus); isToRealDes: \(isToRealDes)")
    }
    
}

