//
//  ToDestinationView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI
import CoreLocation

struct DirectionsView: View {
    // Get Route Info
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    // For Route Map Model
    @EnvironmentObject var mapData: DirectionsMapViewModel
    // Location Manager
    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            DirectionsMapView()
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .top)
            
            VStack {
                Spacer()
                
                VStack {
                    
                    Button(action: mapData.focusRoute) {
                        Image(systemName: mapData.showToSrcRoute ? "point.topleft.down.curvedto.point.filled.bottomright.up" : "point.filled.topleft.down.curvedto.point.bottomright.up")
                            .font(.system(size: 30))
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    
                    Button(action: mapData.focusLocation) {
                        Image(systemName: "scope")
                            .font(.system(size: 25))
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    
                    Button(action: mapData.updateMapType) {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.system(size: 30))
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
        }
        .onAppear {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
            
            //if curLoc.distance(from:desCoord) > 400, add src pin
            mapData.busSrcCoord = CLLocationCoordinate2D(latitude: Double(chosenRoute.srcRS.Stop.lat)!, longitude: Double(chosenRoute.srcRS.Stop.long)!)
            
            mapData.busDesCoord = CLLocationCoordinate2D(latitude: Double(chosenRoute.desRS.Stop.lat)!, longitude: Double(chosenRoute.desRS.Stop.long)!)
            
            mapData.realDesCoord = matchRouteInfo.desCoord
        }
    }
}
