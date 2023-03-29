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
    @EnvironmentObject var mapData: HomeMapViewModel
    
    @State private var srcName = ""
    @State private var desName = ""
    @State var travelTime = 0
    
    var body: some View {
        // Until this Deleted, Keep Command+Z
        VStack {
            List(matchRouteInfo.routesAvailable, id: \.self) {item in
                routePageLink(matchRouteInfo: matchRouteInfo, item: item)
            }
        }
        // Show Search Info
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("🔵 \(srcName)")
                        Text("🔴 \(desName)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text("🚶<\(matchRouteInfo.walkDistance, specifier: "%.f")m")
                }
                .padding()
            }
        }
        .navigationTitle("📍Routes Available")
        .onAppear {
            matchRouteInfo.matchBusRoute()
            
            mapData.getPlaceName(coord: matchRouteInfo.srcCoord) { name in
                srcName = name ?? ""
            }
            
            desName = mapData.selectedPlace[0].title ?? "--"
        }
    }
}
