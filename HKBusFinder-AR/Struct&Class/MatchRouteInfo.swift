//
//  matchRouteInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 1/2/2023.
//

import Foundation
import SwiftUI
import CoreLocation

class MatchRouteInfo: ObservableObject {
    
    // Walking Distance(Adjustable)
    @Published var walkDistance = Double(300)
    
    // From User Location and Place Search
    @Published var srcCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var desCoord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // From JSON Decoder
    @Published var allStops = [stopResult]()
    @Published var allRouteStops = [routeResult]()
    
    // From busStopNearby
    @Published var srcStops = [stopResult]()
    @Published var desStops = [stopResult]()
    
    @Published var routesAvailable = [routeAvailable]()
    
    
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
        
        let srcLocation = CLLocation(latitude: srcCoord.latitude, longitude: srcCoord.longitude)
        let desLocation = CLLocation(latitude: desCoord.latitude, longitude: desCoord.longitude)
        
        for loopStop in allStops {
            let stopLocation = CLLocation(latitude: Double(loopStop.lat)!, longitude: Double(loopStop.long)!)
            
            if (srcLocation.distance(from: stopLocation) <= walkDistance) {
                srcStops.append(loopStop)
            }
            
            if (desLocation.distance(from: stopLocation) <= walkDistance) {
                desStops.append(loopStop)
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
                }
            }
            for desStop in desStops {
                if (routeStop.stop == desStop.stop) {
                    routeStopsAtDes.append(arrRouteStop(routeStop: routeStop, Stop: desStop))
                }
            }
        }
        routeStopsAtSrc = Array(Set(routeStopsAtSrc))
        routeStopsAtDes = Array(Set(routeStopsAtDes))
        
        // If Route Pass through Scr & Des -> routeAvailable
        for RsAtSrc in routeStopsAtSrc {
            for RsAtDes in routeStopsAtDes {
                if (RsAtSrc.routeStop.route == RsAtDes.routeStop.route) && (RsAtSrc.routeStop.bound == RsAtDes.routeStop.bound) && (RsAtSrc.routeStop.service_type == RsAtDes.routeStop.service_type) && (Int(RsAtSrc.routeStop.seq)! < Int(RsAtDes.routeStop.seq)!) {
                    routesAvailable.append(routeAvailable(srcRS: RsAtSrc, desRS: RsAtDes))
                }
            }
        }
        routesAvailable = Array(Set(routesAvailable))
    }
}
