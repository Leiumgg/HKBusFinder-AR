//
//  MapViewModel.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import SwiftUI
import MapKit
import CoreLocation

class HomeMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var mapView = MKMapView()
    
    // Region
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 500, longitudinalMeters: 500)
    // Based on Location it will set up
    
    // Alert
    @Published var permissionDenied = false
    
    // Map Type
    @Published var mapType: MKMapType = .standard
        
    // SearchText
    @Published var searchTxt = ""
    
    // Searched Places
    @Published var places: [Place] = []
    
    // Selected Place
    @Published var selectedPlace: [MKPointAnnotation] = []
    
    // SelectedPin
    @Published var selectedPin = MKPointAnnotation()
    
    // Route Coordinates
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    // Closest Route Node
    @Published var closestRouteCoordinateIndex = 0
    
    // Check Set jor Region Mei
    @Published var hasSetRegion = false
    
    // Clear Search
    func clearSearch() {
        mapView.removeAnnotation(selectedPlace[0])
        selectedPlace = [MKPointAnnotation]()
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
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Focus Location
    func focusDestination() {
        mapView.setRegion(MKCoordinateRegion(center: selectedPlace[0].coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Search Places
    func searchQuery() {
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt
        
        // Fetch
        MKLocalSearch(request: request).start { (response, _) in
            guard let result = response else { return }
            
            self.places = result.mapItems.compactMap({ (item) -> Place? in
                return Place(placemark: item.placemark)
            })
        }
    }
    
    // Search For Place Name
    func getPlaceName(coord: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Reverse geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            if let placemark = placemarks?.first {
                let placeName = placemark.name ?? placemark.locality ?? placemark.subLocality ?? placemark.administrativeArea ?? placemark.country
                completion(placeName)
            } else {
                completion(nil)
            }
        }
    }
    
    // Pick Search Result
    func selectPlace(place: Place) {
        // Showing Pin on Map
        searchTxt = ""
        
        guard let coordinate = place.placemark.location?.coordinate else { return }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "Destination"
        pointAnnotation.subtitle = "Destination"
        
        selectedPlace = [MKPointAnnotation]()
        selectedPlace.append(pointAnnotation)
        
        // Removing All Old Ones
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        mapView.addAnnotation(pointAnnotation)
        
        // Moving Map To That Location
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Select Pin on Direction Map and Scroll View
    func selectPin(pin: MKPointAnnotation) {
        selectedPin = pin
        mapView.selectAnnotation(selectedPin, animated: true)
        mapView.setRegion(MKCoordinateRegion(center: selectedPin.coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
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
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

        // Smooth Animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        
        // Set mapView for once
        if !hasSetRegion {
            self.mapView.setRegion(region, animated: true)
            hasSetRegion = true
        }
    }
}

