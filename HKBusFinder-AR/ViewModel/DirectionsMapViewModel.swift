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
    
    // Alert
    @Published var permissionDenied = false
    
    // Map Type
    @Published var mapType: MKMapType = .standard
    
    // Route Coordinates
    @Published var routeCoordinates = [CLLocationCoordinate2D]()
    
    // Closest Route Node
    @Published var closestRouteCoordinateIndex = 0
    
    // Bus Source Coordinate
    @Published var busSrcCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Bus Destination Coordinate
    @Published var busDesCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Real Source Coordinate
    @Published var realSrcCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Real Destination Coordinate
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
    
    
    // Add Annotation: Stops of Selected Route & Destination
    func pinRouteStops(selectedRSInfo: [seqStopInfo]) {
        mapView.setRegion(region, animated: false)
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Add Annotation
        var busStopsPinList = [MKPointAnnotation]()
        for busStop in selectedRSInfo {
            let busStopPin = MKPointAnnotation()
            busStopPin.title = busStop.stopInfo.name_en
            busStopPin.coordinate = CLLocationCoordinate2D(latitude: Double(busStop.stopInfo.lat)!, longitude: Double(busStop.stopInfo.long)!)
            busStopsPinList.append(busStopPin)
        }
        self.mapView.addAnnotations(busStopsPinList)
        
        // Add Bus Route Line
        let busRouteLine = MKPolyline(coordinates: busStopsPinList.map {$0.coordinate}, count: busStopsPinList.count)
        busRouteLine.title = "busRouteLine"
        mapView.addOverlay(busRouteLine)
        
        pinAdded = true
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
        realSrcAnnotation.title = "Starting Point"
        
        // realDesAnnotation
        let realDesAnnotation = MKPointAnnotation()
        realDesAnnotation.coordinate = realDesCoord
        realDesAnnotation.title = "Destination"
        
        // srcBSAnnotation
        let srcBSAnnotation = MKPointAnnotation()
        srcBSAnnotation.coordinate = busSrcCoord
        srcBSAnnotation.title = "Get On"
        
        // desBSAnnotation
        let desBSAnnotation = MKPointAnnotation()
        desBSAnnotation.coordinate = busDesCoord
        desBSAnnotation.title = "Get Off"
        
        keyAnnotations = [realSrcAnnotation, realDesAnnotation, srcBSAnnotation, desBSAnnotation]
        
        // mapView.annotations = [MyLocation] + keyAnnotation
        self.mapView.addAnnotations(keyAnnotations)
        
        getDirection(Source: realSrcCoord, Destination: busSrcCoord)
        getDirection(Source: busDesCoord, Destination: realDesCoord)
        
        // Draw Bus Line
        let busDotLine = MKPolyline(coordinates: [busSrcCoord, busDesCoord], count: 2)
        busDotLine.title = "busDotLine"
        self.mapView.addOverlay(busDotLine)
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
        if CLLocation(latitude: region.center.latitude, longitude: region.center.longitude).distance(from: CLLocation(latitude: realSrcCoord.latitude, longitude: realSrcCoord.longitude)) <= 310 {
            /// 310 = Walking Distance + 10(buffer)
            isToSrcBS = true
            isToRealDes = false
            isOnBus = false
        } else if CLLocation(latitude: region.center.latitude, longitude: region.center.longitude).distance(from: CLLocation(latitude: realDesCoord.latitude, longitude: realDesCoord.longitude)) <= 310 {
            /// 310 = Walking Distance + 10(buffer)
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
        
        routeCoordinates = [CLLocationCoordinate2D]()
        closestRouteCoordinateIndex = 0
        
        let p1 = MKPlacemark(coordinate: Source)
        let p2 = MKPlacemark(coordinate: Destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {return}
            self.routeCoordinates = route.polyline.coordinates
            /*
            for i in 0..<self.routeCoordinates.count {
                print("\(i): \(self.routeCoordinates[i])")
            }
            print("Point Count: \(route.polyline.pointCount)")
            */
            if (Destination.latitude == self.busSrcCoord.latitude) && (Destination.longitude == self.busSrcCoord.longitude){
                route.polyline.title = "To Bus Stop"
            } else {
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
            hasSetRegion = true
            initPinNDotLine()
        }
        checkTransitStatus()
        
        // Find closest route node
            //change this later for better finding the closest node
        /*
        if !routeCoordinates.isEmpty {
            if closestRouteCoordinateIndex < routeCoordinates.count-1 {
                let curLoc = CLLocation(latitude: routeCoordinates[closestRouteCoordinateIndex].latitude, longitude: routeCoordinates[closestRouteCoordinateIndex].longitude)
                let nextLoc = CLLocation(latitude: routeCoordinates[closestRouteCoordinateIndex+1].latitude, longitude: routeCoordinates[closestRouteCoordinateIndex+1].longitude)
                if nextLoc.distance(from: location) < curLoc.distance(from: location){
                    closestRouteCoordinateIndex += 1
                }
            }
        }
        */
    }
    
}

