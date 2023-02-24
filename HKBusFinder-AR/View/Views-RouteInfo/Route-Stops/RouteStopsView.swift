//
//  RouteStopsScrollView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 11/2/2023.
//

import SwiftUI

struct RouteStopsView: View {
    
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    @EnvironmentObject var mapData: DirectionsMapViewModel
    
    @State var expandItem = seqStopInfo(seq: 0, stopInfo: stopResult(stop: "", name_en: "", lat: "", long: ""))
    
    var body: some View {
        VStack {
            ScrollViewReader { view in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(matchRouteInfo.selectedRSInfo, id: \.self) { item in
                            StopInfoView(matchRouteInfo: matchRouteInfo, view: view, item: item, expandItem: expandItem)
                                .environmentObject(mapData)
                                .onTapGesture {
                                    mapData.selectPin(pinName: item.stopInfo.name_en)
                                    withAnimation {
                                        view.scrollTo(item, anchor: .center)
                                        expandItem = item
                                    }
                                    matchRouteInfo.loadRouteStopETA(stopID: item.stopInfo.stop, route: matchRouteInfo.chosenRoute[0].srcRS.routeStop.route, serviceType: matchRouteInfo.chosenRoute[0].srcRS.routeStop.service_type)
                                }
                            
                            Divider()
                        }
                    }
                }
                .background(Color.white)
            }
        }
    }
    
}

struct StopInfoView: View {
    @State var stopExpandETA = false
    
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    @EnvironmentObject var mapData: DirectionsMapViewModel
    
    var view: ScrollViewProxy
    var item: seqStopInfo
    var expandItem: seqStopInfo
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if item.stopInfo.stop == matchRouteInfo.chosenRoute[0].srcRS.Stop.stop {
                    Color.green
                } else if item.stopInfo.stop == matchRouteInfo.chosenRoute[0].desRS.Stop.stop {
                    Color.orange
                } else {
                    Color.white
                }
                
                VStack {
                    Text(item.stopInfo.stop == matchRouteInfo.chosenRoute[0].srcRS.Stop.stop ? "\(item.seq): \(item.stopInfo.name_en)" : item.stopInfo.stop == matchRouteInfo.chosenRoute[0].desRS.Stop.stop ? "\(item.seq): \(item.stopInfo.name_en)" : "\(item.seq): \(item.stopInfo.name_en)")
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(item.stopInfo.stop == matchRouteInfo.chosenRoute[0].srcRS.Stop.stop ? Color.green : item.stopInfo.stop == matchRouteInfo.chosenRoute[0].desRS.Stop.stop ? Color.orange : Color.white)
                        .padding()
                    
                    
                    if expandItem == item {
                        VStack {
                            ForEach(matchRouteInfo.routeStopETA, id: \.self) { etaItem in
                                VStack(alignment: .leading) {
                                    let dateFormatter = ISO8601DateFormatter()
                                    let dateString = etaItem.eta
                                    if let date = dateFormatter.date(from: dateString ?? "") {
                                        let timeInverval = (date.timeIntervalSinceNow/60).rounded(.down)
                                        Text("\(etaItem.rmk_en == "" ? "Estimated Time" : etaItem.rmk_en): \(timeInverval, specifier: "%.f")min")
                                            .foregroundColor(.black)
                                    } else {
                                        Text("-- --")
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding([.bottom,.horizontal])
                            }
                        }
                    }
                } // VStack
            } // ZStack
        } //VStack(spacing: 0)
    }
}
