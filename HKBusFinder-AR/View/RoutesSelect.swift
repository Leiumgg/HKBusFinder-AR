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
                        Text("Source")
                        Text("Destination")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Distance") {}
                }
                .padding()
            }
        }
        .navigationTitle("📍Routes Available")
        .onAppear {
            matchRouteInfo.matchBusRoute()
        }
    }
}

struct RoutesSelect_Previews: PreviewProvider {
    static var previews: some View {
        RoutesSelect(matchRouteInfo: MatchRouteInfo())
    }
}

