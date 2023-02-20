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
    
    var body: some View {
        VStack {
            ScrollViewReader { view in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(matchRouteInfo.selectedRSInfo, id: \.self) { item in
                            ZStack {
                                if item.stopInfo.stop == matchRouteInfo.chosenRoute[0].srcRS.Stop.stop {
                                    Color.green
                                } else if item.stopInfo.stop == matchRouteInfo.chosenRoute[0].desRS.Stop.stop {
                                    Color.orange
                                } else {
                                    Color.white
                                }
                                
                                Text(item.stopInfo.stop == matchRouteInfo.chosenRoute[0].srcRS.Stop.stop ? "\(item.seq): \(item.stopInfo.name_en)" : item.stopInfo.stop == matchRouteInfo.chosenRoute[0].desRS.Stop.stop ? "\(item.seq): \(item.stopInfo.name_en)" : "\(item.seq): \(item.stopInfo.name_en)")
                                    .foregroundColor(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(item.stopInfo.stop == matchRouteInfo.chosenRoute[0].srcRS.Stop.stop ? Color.green : item.stopInfo.stop == matchRouteInfo.chosenRoute[0].desRS.Stop.stop ? Color.orange : Color.white)
                                    .onTapGesture {
                                        mapData.selectPin(pinName: item.stopInfo.name_en)
                                        withAnimation {
                                            view.scrollTo(item, anchor: .center)
                                        }
                                    }
                                    .padding()
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

/*
struct ExpandingView: View {
    
    @State var isExpanded = false
    var id: Int
    var proxy: ScrollViewProxy
    var body: some View {
        VStack {
            Text("Hello!")
            if isExpanded {
                Text("World")
            }
        }
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }
}
struct TestScrollView: View {
    var body: some View {
        ScrollViewReader { view in
            ScrollView {
                ForEach(0...100, id: \.self) { id in
                    ExpandingView(id: id, proxy: view)
                        .id(id)
                        .padding()
                }
            }
        }
    }
}
*/
