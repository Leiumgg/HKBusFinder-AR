//
//  MtrRouteInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/3/2023.
//

import SwiftUI

struct MtrRouteInfo: View {
    @StateObject var mapData = DirectionsMapViewModel()
    
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedTab == 0 {
                    VStack {
                        ZStack {
                            DirectionsView(matchRouteInfo: matchRouteInfo)
                                .environmentObject(mapData)
                        }                    }
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
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: { self.selectedTab = 1 }) {
                        VStack {
                            Image(systemName: selectedTab == 1 ? "location.fill.viewfinder" : "location.viewfinder")
                                .imageScale(.large)
                            Text("AR Direct")
                                .font(.caption2)
                        }
                        .foregroundColor(.gray)
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
                        Image(systemName: "tram.fill.tunnel")
                            .foregroundColor(Color.red)
                        Text("MTR")
                    }
                }
            }
        }
        .onAppear {
            matchRouteInfo.chosenRoute = [chosenRoute]
            
            // Walking Distance + 10m buffer
            mapData.walkingDistance = matchRouteInfo.walkDistance + 10
        }
    }
}
