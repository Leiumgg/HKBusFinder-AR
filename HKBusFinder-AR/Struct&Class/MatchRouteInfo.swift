//
//  matchRouteInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 1/2/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

class MatchRouteInfo: ObservableObject {
    
    // Walking Distance(Adjustable)
    @Published var walkDistance = 300.0
    
    // From User Location and Place Search
    @Published var srcCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var desCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // From JSON Decoder
    @Published var allStops = [stopResult]()
    @Published var allRouteStops = [routeResult]()
    
    // From busStopNearby
    @Published var srcStops = [stopResult]()
    @Published var desStops = [stopResult]()
    @Published var srcStopsPin = [MKPointAnnotation]()
    @Published var desStopsPin = [MKPointAnnotation]()
    
    @Published var routesAvailable = [routeAvailable]()
    
    // The Stops Info of Selected Route in Sequence
    @Published var selectedRSs = [routeResult]()
    @Published var selectedRSInfo = [seqStopInfo]()
    
    // To Store Chosen Route
    @Published var chosenRoute = [routeAvailable]()
    
    // Source Bus Stop ETA
    @Published var srcStopETA = [etaResult]()
    
    // Route Stop ETA
    @Published var routeStopETA = [etaResult]()
    
    // All ETA of A Bus Stop
    @Published var stopAllETA = [etaResult]()
    
    // Load All ETA of One Bus Stop
    func loadStopAllETA(stop: String) {
        guard let url = URL(string: "https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/\(stop)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { fdata, response, error in
            if let fdata = fdata {
                if let decodedResponse = try? JSONDecoder().decode(etaResponse.self, from: fdata) {
                    DispatchQueue.main.async {
                        self.stopAllETA = decodedResponse.data
                    }
                    return
                }
            }
            print(url)
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    // Load Bus Stops Info of Selected Route by Local Array Loop
    func loadSeqStopInfo(routeRS: routeResult) {
        selectedRSs = [routeResult]()
        selectedRSInfo = [seqStopInfo]()
        var foundit = false
        for RS in allRouteStops {
            if (RS.route == routeRS.route) && (RS.bound == routeRS.bound) && (RS.service_type == routeRS.service_type) {
                foundit = true
                selectedRSs.append(RS)
            } else {
                foundit = false
            }
            if !selectedRSs.isEmpty && !foundit {
                break
            }
        }
        
        for allStop in allStops {
            for selectedRS in selectedRSs {
                if allStop.stop == selectedRS.stop {
                    selectedRSInfo.append(seqStopInfo(seq: Int(selectedRS.seq)!, stopInfo: allStop))
                }
            }
        }
        selectedRSInfo = selectedRSInfo.sorted {$0.seq < $1.seq}
    }
    
    // loadStopsData from JSON URL
    func loadStopsData() {
        guard let url = URL(string: "https://data.etabus.gov.hk/v1/transport/kmb/stop") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { fdata, response, error in
            if let fdata = fdata {
                if let decodedResponse = try? JSONDecoder().decode(stopResponse.self, from: fdata) {
                    DispatchQueue.main.async {
                        self.allStops = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    // loadRouteStopETA
    func loadRouteStopETA(stopID: String, route: String, serviceType: String) {
        guard let url = URL(string: "https://data.etabus.gov.hk/v1/transport/kmb/eta/\(stopID)/\(route)/\(serviceType)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { fdata, response, error in
            if let fdata = fdata {
                if let decodedResponse = try? JSONDecoder().decode(etaResponse.self, from: fdata) {
                    DispatchQueue.main.async {
                        self.routeStopETA = decodedResponse.data
                    }
                    return
                }
            }
            print(url)
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    // loadSrcETAData from JSON URL
    func loadSrcETAData(stopID: String, route: String, serviceType: String) {
        guard let url = URL(string: "https://data.etabus.gov.hk/v1/transport/kmb/eta/\(stopID)/\(route)/\(serviceType)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { fdata, response, error in
            if let fdata = fdata {
                if let decodedResponse = try? JSONDecoder().decode(etaResponse.self, from: fdata) {
                    DispatchQueue.main.async {
                        self.srcStopETA = decodedResponse.data
                    }
                    return
                }
            }
            print(url)
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    // MapKit Calculate Transit ETA
    func MKTransitETA(p1: MKPlacemark, p2: MKPlacemark, completion: @escaping (Int) -> Void){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .transit
        
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
    
    // loadRouteStopsData from JSON URL
    func loadRouteStopsData() {
        guard let url = URL(string: "https://data.etabus.gov.hk/v1/transport/kmb/route-stop") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { fdata, response, error in
            if let fdata = fdata {
                if let decodedResponse = try? JSONDecoder().decode(routeResponse.self, from: fdata) {
                    DispatchQueue.main.async {
                        self.allRouteStops = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    // Find bus Stops near Source and Destination
    func busStopNearby() {
        srcStops = [stopResult]()
        desStops = [stopResult]()
        srcStopsPin = [MKPointAnnotation]()
        desStopsPin = [MKPointAnnotation]()
        
        let srcLocation = CLLocation(latitude: srcCoord.latitude, longitude: srcCoord.longitude)
        let desLocation = CLLocation(latitude: desCoord.latitude, longitude: desCoord.longitude)
        
        for loopStop in allStops {
            let stopLocation = CLLocation(latitude: Double(loopStop.lat)!, longitude: Double(loopStop.long)!)
            
            if (srcLocation.distance(from: stopLocation) <= walkDistance) {
                srcStops.append(loopStop)
                
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.title = loopStop.name_en
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double(loopStop.lat)!, longitude: Double(loopStop.long)!)
                pointAnnotation.subtitle = loopStop.stop
                srcStopsPin.append(pointAnnotation)
            }
            
            if (desLocation.distance(from: stopLocation) <= walkDistance) {
                desStops.append(loopStop)
                
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.title = loopStop.name_en
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double(loopStop.lat)!, longitude: Double(loopStop.long)!)
                pointAnnotation.subtitle = loopStop.stop
                desStopsPin.append(pointAnnotation)
            }
        }
        
        srcStops = Array(Set(srcStops))
        desStops = Array(Set(desStops))
    }
    
    // Find Routes Available
    func matchBusRoute() {
        var routeStopsAtSrc = [arrRouteStop]()
        var routeStopsAtDes = [arrRouteStop]()
        
        // Initialize routesAvailable = []
        routesAvailable = [routeAvailable]()
        
        // Find All Routes near Source & Destination
        for routeStop in allRouteStops {
            for srcStop in srcStops {
                if (routeStop.stop == srcStop.stop) {
                    routeStopsAtSrc.append(arrRouteStop(routeStop: routeStop, Stop: srcStop))
                    break
                }
            }
            for desStop in desStops {
                if (routeStop.stop == desStop.stop) {
                    routeStopsAtDes.append(arrRouteStop(routeStop: routeStop, Stop: desStop))
                    break
                }
            }
        }
        
        // If Route Pass through Scr & Des -> routeAvailable
        for RsAtSrc in routeStopsAtSrc {
            for RsAtDes in routeStopsAtDes {
                if (RsAtSrc.routeStop.route == RsAtDes.routeStop.route) && (RsAtSrc.routeStop.bound == RsAtDes.routeStop.bound) && (Int(RsAtSrc.routeStop.service_type) == 1) && (Int(RsAtDes.routeStop.service_type) == 1) && (Int(RsAtSrc.routeStop.seq)! < Int(RsAtDes.routeStop.seq)!) { // Service Type only Consider: 1
                    routesAvailable.append(routeAvailable(srcRS: RsAtSrc, desRS: RsAtDes))
                }
            }
        }
    }
    
}
