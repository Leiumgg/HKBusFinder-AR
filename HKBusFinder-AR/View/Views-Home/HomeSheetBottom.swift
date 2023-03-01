//
//  HomeSheetView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 27/2/2023.
//

import SwiftUI
import MapKit

struct HomeSheetBottom: View {
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    @EnvironmentObject var mapData: HomeMapViewModel
    
    @State private var selectedTab = 1
    private var tabList: [Int] {
        var list = [0, 1]
        if !mapData.selectedPlace.isEmpty {
            list.append(2)
        }
        return list
    }
    
    @State var expandItem = MKPointAnnotation()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Picker", selection: $selectedTab) {
                    ForEach(tabList, id: \.self) { item in
                        Text("\(item == 0 ? "Pick a Location" : item == 1 ? "Your Location" : "\(mapData.selectedPlace[0].title!)")")
                    }
                }
                .tint(.white)
                .frame(maxWidth: .infinity)
                
                Text("\(selectedTab == 1 ? "\(matchRouteInfo.srcStops.count)" : selectedTab == 2 ? "\(mapData.selectedPlace.isEmpty ? "--" : "\(matchRouteInfo.desStops.count)")" : "--") Stops Nearby")
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
            }
            
            Divider()
            
            ScrollViewReader { view in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach((selectedTab == 1 ? matchRouteInfo.srcStopsPin : selectedTab == 2 && !mapData.selectedPlace.isEmpty ? matchRouteInfo.desStopsPin : [MKPointAnnotation]()), id: \.self) { item in
                            StopETAView(matchRouteInfo: matchRouteInfo, view: view, item: item, expandItem: expandItem)
                                .contentShape(Rectangle())
                                .environmentObject(mapData)
                                .onTapGesture {
                                    withAnimation {
                                        mapData.selectPin(pin: item)
                                        view.scrollTo(item, anchor: .center)
                                    }
                                    matchRouteInfo.loadStopAllETA(stop: item.subtitle!)
                                }
                            
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

struct StopETAView: View {
    @State var stopExpandETA = false
    
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    @EnvironmentObject var mapData: HomeMapViewModel
    
    var view: ScrollViewProxy
    var item: MKPointAnnotation
    var expandItem: MKPointAnnotation
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("\(item.title!)")
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Text("\(CLLocation(latitude: mapData.region.center.latitude, longitude: mapData.region.center.longitude).distance(from: CLLocation(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude)), specifier: "%.f")m")
                        .foregroundColor(Color.white)
                        .padding()
                }
                
                if mapData.selectedPin == item {
                    VStack {
                        ForEach(matchRouteInfo.stopAllETA, id: \.self) { etaItem in
                            VStack(alignment: .leading) {
                                let date = ISO8601DateFormatter().date(from: etaItem.eta ?? "")
                                HStack {
                                    Text("\(etaItem.route)")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                    
                                    Text("To \(etaItem.dest_en)")
                                        .foregroundColor(Color.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("\(date == nil ? Double.nan : date!.timeIntervalSinceNow/60.rounded(.down), specifier: "%.f") min")
                                        .foregroundColor(Color.white)
                                }
                            }
                            .padding()
                        }
                    }
                    .background(BlurView(style: .dark)
                        .clipShape(CustomCorner(corners: [], radius: 0))
                    )
                }
            } // VStack
        } // ZStack
    }
}

struct HomeSheetBottomView_Preview: PreviewProvider {
    static var previews: some View {
        HomeSheetBottom(matchRouteInfo: MatchRouteInfo())
            .environmentObject(HomeMapViewModel())
    }
}
