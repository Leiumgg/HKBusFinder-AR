//
//  OnBusView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI
import CoreLocation

struct RouteStopsView: View {
    // Get Route Info
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    // For Route Map Model
    @EnvironmentObject var mapData: DirectionsMapViewModel
    // Location Manager
    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            VStack {
                RouteStopsMapView()
                    .environmentObject(mapData)
                
                RouteStopsScrollView()
            }
        }
    }
}
