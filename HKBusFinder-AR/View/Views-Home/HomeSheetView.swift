//
//  HomeSheetView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 27/2/2023.
//

import SwiftUI

struct HomeSheetView: View {
    @State var searchText = ""
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    var height: CGFloat
    
    @EnvironmentObject var mapData: HomeMapViewModel
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    
    @State private var srcName = ""
    
    var body: some View {
        ZStack {
            
            BlurView(style: .systemThinMaterialDark)
                .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
            
            VStack {
                
                VStack {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 80, height: 4)
                    
                    // Initial Sheet View: User Location or Destination
                    if mapData.selectedPlace.isEmpty {
                        VStack {
                            Text("Your Location:")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .colorScheme(.dark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(srcName)")
                                .padding(.horizontal)
                                .colorScheme(.dark)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        NavigationLink(destination: RoutesSelect(matchRouteInfo: matchRouteInfo).environmentObject(mapData)) {
                            HStack {
                                Text("Route: ")
                                    .font(.headline)
                                    .colorScheme(.dark)
                                
                                Text("\(mapData.selectedPlace[0].title ?? "Destination")")
                                    .colorScheme(.dark)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "location.fill")
                                    .font(.title3)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .colorScheme(.dark)
                        .background(BlurView(style: .dark)
                            .clipShape(CustomCorner(corners: [.allCorners], radius: 10))
                        )
                    }
                }
                .frame(height: 100)
                
                // ScrollView Content
                ScrollView(.vertical, showsIndicators: false) {
                    HomeSheetBottom(matchRouteInfo: matchRouteInfo)
                        .environmentObject(mapData)
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .offset(y: height - 100)
        .offset(y: -offset > 0 ? -offset <= (height-100) ? offset : -(height-100) : 0)
        .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
            out = value.translation.height
            onChange()
        }).onEnded({ value in
            let maxHeight = height - 100
            withAnimation {
                // Logical Condition, medium, full screen ...
                if -offset > 100 && -offset < maxHeight/1.5 {
                    // Mid
                    offset = -(maxHeight/2.5)
                } else if -offset > maxHeight/1.5 {
                    // Full
                    offset = -maxHeight
                } else {
                    offset = 0
                }
            }
            // Store last offset
            lastOffset = offset
        }))
        .onChange(of: mapData.hasSetRegion) { newValue in
            mapData.getPlaceName(coord: mapData.region.center) { name in
                self.srcName = name ?? ""
            }
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
    
    func getBlurRadius() -> CGFloat {
        let progress = -offset / (UIScreen.main.bounds.height-100)
        return progress * 30
    }
}
