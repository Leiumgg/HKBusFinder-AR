//
//  RouteInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import SwiftUI
import CoreLocation

struct RoutesSelect: View {
    // Use the matchRouteInfo as observedObject
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    
    @State private var srcName = ""
    @State private var desName = ""
    
    var body: some View {
        
        List(matchRouteInfo.routesAvailable, id: \.self) {item in
            NavigationLink(destination: RouteInfo(matchRouteInfo: matchRouteInfo, chosenRoute: item)) {
                HStack {
                    Text(item.srcRS.routeStop.route).padding(.trailing)
                    VStack(alignment: .leading) {
                        Text(item.srcRS.Stop.name_en)
                        Text(item.desRS.Stop.name_en)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text("ETA")
                        .foregroundColor(.green)
                }
            }
        }
        // For Search Adjustment
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("🟢 \(srcName)")
                        Text("🟠 \(desName)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text("🚶\(matchRouteInfo.walkDistance, specifier: "%.f")m")
                }
                .padding()
            }
        }
        .navigationTitle("📍Routes Available")
        .onAppear {
            matchRouteInfo.busStopNearby()
            matchRouteInfo.matchBusRoute()
            
            getPlaceName(coord: matchRouteInfo.srcCoord) { name in
                srcName = name ?? ""
            }
            // Need Change to The Search Result
            getPlaceName(coord: matchRouteInfo.desCoord) { name in
                desName = name ?? ""
            }
        }
    }
    
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
}

struct RoutesSelect_Previews: PreviewProvider {
    static var previews: some View {
        RoutesSelect(matchRouteInfo: MatchRouteInfo())
    }
}

