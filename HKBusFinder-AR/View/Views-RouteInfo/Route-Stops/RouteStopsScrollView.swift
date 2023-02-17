//
//  RouteStopsScrollView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 11/2/2023.
//

import SwiftUI

struct RouteStopsScrollView: View {
    
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    
    var body: some View {
        VStack {
            ScrollViewReader { view in
                ScrollView {
                    ForEach(matchRouteInfo.selectedRSInfo, id: \.self) { item in
                        Text("\(item.seq): \(item.stopInfo.name_en)")
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .onTapGesture {
                                print("tapped on \(item.seq)")
                                withAnimation {
                                    view.scrollTo(item, anchor: .center)
                                }
                            }
                            .padding(.horizontal)
                        
                        Divider()
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
