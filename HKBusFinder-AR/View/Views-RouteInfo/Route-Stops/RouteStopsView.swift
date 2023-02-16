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
    
    // For Route Map Model
    @StateObject var mapData = DirectionsMapViewModel()
    // Location Manager
    @State var locationManager = CLLocationManager()
    
    @State private var mapEnlarge = false
    
    var body: some View {
        ZStack {
            VStack {
                
                ZStack {
                    RouteStopsMapView(matchRouteInfo: matchRouteInfo)
                        .environmentObject(mapData)
                        .ignoresSafeArea(.all)
                    
                    // Map Scale Button
                    VStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                if mapEnlarge {
                                    mapEnlarge.toggle()
                                } else {
                                    mapEnlarge.toggle()
                                }
                            }
                        } label: {
                            Image(systemName: mapEnlarge ? "viewfinder.circle" : "viewfinder.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Function Button
                    VStack {
                        Spacer()
                        
                        VStack {
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
                
                RouteStopsScrollView(matchRouteInfo: matchRouteInfo)
                    .frame(height: mapEnlarge ? 400 : 150)
            }
        }
        .onAppear {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
            
            matchRouteInfo.loadSeqStopInfo(routeRS: matchRouteInfo.chosenRoute[0].srcRS.routeStop)
        }
    }
}
