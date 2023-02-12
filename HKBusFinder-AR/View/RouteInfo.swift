//
//  RouteInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI

struct RouteInfo: View {
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    // mapData
    @StateObject var mapData = DirectionsMapViewModel()
    
    var body: some View {
        TabView {
            
            DirectionsView(matchRouteInfo: matchRouteInfo, chosenRoute: chosenRoute)
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Directions")
                }
            
            RouteStopsView(matchRouteInfo: matchRouteInfo, chosenRoute: chosenRoute)
                .tabItem {
                    Image(systemName: "bus")
                    Text("On Bus")
                }
            
            ToStopView(matchRouteInfo: matchRouteInfo, chosenRoute: chosenRoute)
                .tabItem {
                    Image(systemName: "clock")
                    Text("To Stop")
                }
            
            // AR Guide
            
        }
        .environmentObject(mapData)
    }
}
