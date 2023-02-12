//
//  RouteStopsScrollView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 11/2/2023.
//

import SwiftUI

struct RouteStopsScrollView: View {
    
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    var chosenRoute: routeAvailable
    
    var body: some View {
        VStack {
            List(matchRouteInfo.selectedRSInfo, id: \.self) { item in
                Text("\(item.seq): \(item.stopInfo.name_en)")
            }
        }
        .onAppear {
            matchRouteInfo.loadSeqStopInfo(routeRS: chosenRoute.srcRS.routeStop)
        }
    }
    
}
