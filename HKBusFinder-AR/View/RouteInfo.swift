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
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedTab == 0 {
                    DirectionsView(matchRouteInfo: matchRouteInfo)
                } else if selectedTab == 1 {
                    RouteStopsView(matchRouteInfo: matchRouteInfo)
                } else {
                    // AR VIEW !!!!!!!!!
                    Nothing2View()
                }
                
                Spacer()
                
                // Bottom Tab Bar in Navigation Style
                HStack {
                    Button(action: { self.selectedTab = 0 }) {
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
                            Image(systemName: selectedTab == 1 ? "bus.doubledecker" : "bus.doubledecker.fill")
                                .fontWeight(selectedTab == 1 ? .medium : .ultraLight)
                                .imageScale(.large)
                            Text("Route Info")
                                .font(.caption2)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    }
                    Button(action: { self.selectedTab = 2 }) {
                        VStack {
                            Image(systemName: selectedTab == 2 ? "location.fill.viewfinder" : "location.viewfinder")
                                .imageScale(.large)
                            Text("AR Pointer")
                                .font(.caption2)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            matchRouteInfo.chosenRoute = [chosenRoute]
        }
    }
}
