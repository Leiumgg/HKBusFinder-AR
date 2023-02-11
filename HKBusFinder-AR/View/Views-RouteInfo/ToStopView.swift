//
//  ToStopView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI
import CoreLocation

struct ToStopView: View {
    // Get Route Info
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    // For Route Map Model
    @StateObject var mapData = ToStopRouteMapViewModel()
    // Location Manager
    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            ToStopRouteMapView()
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .top)
            
            VStack {
                Spacer()
                
                VStack {
                    
                    Button(action: mapData.focusRoute) {
                        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
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
            
            mapData.desCoord = CLLocationCoordinate2D(latitude: Double(chosenRoute.srcRS.Stop.lat)!, longitude: Double(chosenRoute.srcRS.Stop.long)!)
        }
    }
}
/*
struct ToStopView_Previews: PreviewProvider {
    static var previews: some View {
        ToStopView(matchRouteInfo: MatchRouteInfo())
    }
}
*/
