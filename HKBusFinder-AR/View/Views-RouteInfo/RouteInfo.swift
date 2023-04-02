//
//  RouteInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 6/2/2023.
//

import SwiftUI

struct RouteInfo: View {
    @StateObject var mapData = DirectionsMapViewModel()
    
    @EnvironmentObject var selectionMapData: HomeMapViewModel
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    @State private var selectedTab = 0
    
    @State private var bigMapForT1 = true
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedTab <= 1 {
                    VStack {
                        ZStack {
                            DirectionsView(matchRouteInfo: matchRouteInfo)
                                .environmentObject(mapData)
                            
                            // Enlarge Map Button For "Route Info" Tab
                            if selectedTab == 1 {
                                VStack {
                                    Spacer()
                                    
                                    Button {
                                        withAnimation {
                                            bigMapForT1.toggle()
                                        }
                                    } label: {
                                        Image(systemName: bigMapForT1 ? "viewfinder.circle" : "viewfinder.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            }
                        }
                        if selectedTab == 1 {
                            RouteStopsView(matchRouteInfo: matchRouteInfo)
                                .frame(height: bigMapForT1 ? 300 : 150)
                                .environmentObject(mapData)
                        }
                    }
                } else {
                    // AR VIEW !!!!!!!!!
                    ARDirectView(matchRouteInfo: matchRouteInfo)
                        .environmentObject(mapData)
                }
                
                Spacer()
                
                // Bottom Tab Bar in Navigation Style
                HStack {
                    Button(action: {
                        withAnimation {
                            self.selectedTab = 0
                        }
                    }) {
                        VStack {
                            Image(systemName: "mappin.and.ellipse")
                                .imageScale(.large)
                                .fontWeight(selectedTab == 0 ? .black : .light)
                            Text("Get On/Off")
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                    Button(action: {
                        withAnimation {
                            self.selectedTab = 1
                        }
                    }) {
                        VStack {
                            Image(systemName: selectedTab == 1 ? "bus.doubledecker" : "bus.doubledecker.fill")
                                .fontWeight(selectedTab == 1 ? .medium : .ultraLight)
                                .imageScale(.large)
                            Text("Route Info")
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                    Button(action: { self.selectedTab = 2 }) {
                        VStack {
                            Image(systemName: selectedTab == 2 ? "location.fill.viewfinder" : "location.viewfinder")
                                .imageScale(.large)
                                .fontWeight(selectedTab == 2 ? .heavy : .medium)
                            Text("AR Direct")
                                .font(.caption2)
                        }
                        .foregroundColor(mapData.isOnBus && !mapData.isToSrcBS && !mapData.isToRealDes ? .gray : .white)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(mapData.isOnBus && !mapData.isToSrcBS && !mapData.isToRealDes)
                }
                .padding(.horizontal)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                VStack(alignment: .trailing) {
                    HStack {
                        if mapData.isToSrcBS {
                            Image(systemName: "clock")
                                .foregroundColor(Color.red)
                                .fontWeight(.bold)
                            if !matchRouteInfo.srcStopETA.isEmpty {
                                let dateFormatter = ISO8601DateFormatter()
                                let dateString = matchRouteInfo.srcStopETA.first!.eta
                                if let date = dateFormatter.date(from: dateString ?? "") {
                                    let timeInterval = (date.timeIntervalSinceNow/60).rounded(.down)
                                    if timeInterval < 0 {
                                        Text("--")
                                            .foregroundColor(.red)
                                            .onAppear {
                                                mapData.formattedETA = Int(timeInterval)
                                            }
                                    } else {
                                        Text("\(timeInterval, specifier: "%.f") min")
                                            .onAppear {
                                                mapData.formattedETA = Int(timeInterval)
                                            }
                                    }
                                }
                            }
                        } else if mapData.isToRealDes {
                            Text("Off Bus")
                        } else {
                            if selectionMapData.selectedSrcPlace.isEmpty {
                                Text("On Bus")
                            } else {
                                Image(systemName: "clock")
                                    .foregroundColor(Color.red)
                                    .fontWeight(.bold)
                                if !matchRouteInfo.srcStopETA.isEmpty {
                                    let dateFormatter = ISO8601DateFormatter()
                                    let dateString = matchRouteInfo.srcStopETA.first!.eta
                                    if let date = dateFormatter.date(from: dateString ?? "") {
                                        let timeInterval = (date.timeIntervalSinceNow/60).rounded(.down)
                                        if timeInterval < 0 {
                                            Text("--")
                                                .foregroundColor(.red)
                                                .onAppear {
                                                    mapData.formattedETA = Int(timeInterval)
                                                }
                                        } else {
                                            Text("\(timeInterval, specifier: "%.f") min")
                                                .onAppear {
                                                    mapData.formattedETA = Int(timeInterval)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Image(systemName: "bus.doubledecker.fill")
                            .foregroundColor(Color.red)
                        Text(chosenRoute.srcRS.routeStop.route)
                    }
                }
            }
        }
        .onAppear {
            matchRouteInfo.chosenRoute = [chosenRoute]
            
            matchRouteInfo.loadSrcETAData(stopID: chosenRoute.srcRS.Stop.stop, route: chosenRoute.srcRS.routeStop.route, serviceType: chosenRoute.srcRS.routeStop.service_type)
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                matchRouteInfo.loadSrcETAData(stopID: chosenRoute.srcRS.Stop.stop, route: chosenRoute.srcRS.routeStop.route, serviceType: chosenRoute.srcRS.routeStop.service_type)
            }
            
            // Walking Distance + 10m buffer
            mapData.walkingDistance = matchRouteInfo.walkDistance + 10
        }
    }
}
