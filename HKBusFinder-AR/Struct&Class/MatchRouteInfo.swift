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
    @Published var routeStopsAtSrc = [arrRouteStop]()
    @Published var routeStopsAtDes = [arrRouteStop]()
    
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
    
    // MTR Stations Coordinates
    @Published var allMtrStations = mtrStation.allStations
    
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
                        self.stopAllETA = decodedResponse.data.filter {$0.eta_seq == 1}
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
        
        // Loop for Getting RouteStop of NearbyStops
        routeStopsAtSrc = [arrRouteStop]()
        routeStopsAtDes = [arrRouteStop]()
        
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
    }
    
    // Find Routes Available
    func matchBusRoute() {
        var unfilterAvailable = [routeAvailable]()
        routesAvailable = [routeAvailable]()
        
        // If Route Pass through Scr & Des -> routeAvailable
        for RsAtSrc in routeStopsAtSrc {
            for RsAtDes in routeStopsAtDes {
                if (RsAtSrc.routeStop.route == RsAtDes.routeStop.route) && (RsAtSrc.routeStop.bound == RsAtDes.routeStop.bound) && (Int(RsAtSrc.routeStop.service_type) == 1) && (Int(RsAtDes.routeStop.service_type) == 1) && (Int(RsAtSrc.routeStop.seq)! < Int(RsAtDes.routeStop.seq)!) { // Service Type only Consider: 1
                    
                    let srcWalkingDistance = CLLocation(latitude: Double(RsAtSrc.Stop.lat)!, longitude: Double(RsAtSrc.Stop.long)!).distance(from: CLLocation(latitude: srcCoord.latitude, longitude: srcCoord.longitude))
                    let desWalkingDistance = CLLocation(latitude: Double(RsAtDes.Stop.lat)!, longitude: Double(RsAtDes.Stop.long)!).distance(from: CLLocation(latitude: desCoord.latitude, longitude: desCoord.longitude))
                    let walkingDistance = srcWalkingDistance + desWalkingDistance
                    
                    unfilterAvailable.append(routeAvailable(srcRS: RsAtSrc, desRS: RsAtDes, totalDistance: walkingDistance))
                    
                }
            }
        }
        
        // Optimize Route Search by Walking Distance
        var shortestDistances = [String: Double]()
        var result = [routeAvailable]()
        
        for loopRoute in unfilterAvailable {
            if shortestDistances[loopRoute.srcRS.routeStop.route] == nil || loopRoute.totalDistance < shortestDistances[loopRoute.srcRS.routeStop.route]! {
                shortestDistances[loopRoute.srcRS.routeStop.route] = loopRoute.totalDistance
                result.removeAll {$0.srcRS.routeStop.route == loopRoute.srcRS.routeStop.route}
                result.append(loopRoute)
            }
        }
        
        let sortedResult = result.sorted(by: {$0.totalDistance < $1.totalDistance})
        
        for i in sortedResult {
            routesAvailable.append(i)
        }
        
        // MTR Option
        var srcStation = [mtrStation]()
        var desStation = [mtrStation]()
        var srcDistance = walkDistance + 50
        var desDistance = walkDistance + 50
        
        for station in allMtrStations {
            let src2src = CLLocation(latitude: Double(station.lat)!, longitude: Double(station.long)!).distance(from: CLLocation(latitude: srcCoord.latitude, longitude: srcCoord.longitude))
            let des2des = CLLocation(latitude: Double(station.lat)!, longitude: Double(station.long)!).distance(from: CLLocation(latitude: desCoord.latitude, longitude: desCoord.longitude))
            
            if src2src < srcDistance {
                srcStation = [mtrStation]()
                srcStation.append(station)
                srcDistance = src2src
            }
            if des2des < desDistance {
                desStation = [mtrStation]()
                desStation.append(station)
                desDistance = des2des
            }
        }
        
        if (!srcStation.isEmpty) && (!desStation.isEmpty) {
            if srcStation[0] != desStation[0] {
                let mtrRoute = routeAvailable(srcRS: arrRouteStop(routeStop: routeResult(route: "MTR", bound: "", service_type: "", seq: "", stop: ""), Stop: stopResult(stop: "", name_en: srcStation[0].name, lat: srcStation[0].lat, long: srcStation[0].long)), desRS: arrRouteStop(routeStop: routeResult(route: "MTR", bound: "", service_type: "", seq: "", stop: ""), Stop: stopResult(stop: "", name_en: desStation[0].name, lat: desStation[0].lat, long: desStation[0].long)), totalDistance: srcDistance + desDistance)
                
                routesAvailable.append(mtrRoute)
            }
        }
    }
    
}
