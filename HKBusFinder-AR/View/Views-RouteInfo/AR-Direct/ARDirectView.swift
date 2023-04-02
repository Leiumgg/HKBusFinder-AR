//
//  ARDirectView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 18/2/2023.
//

import SwiftUI
import CoreLocation

struct ARDirectView: View {
    @StateObject var ARData = ARMapViewModel()
    @EnvironmentObject var mapData: DirectionsMapViewModel
    @ObservedObject var matchRouteInfo: MatchRouteInfo
    
    @State var locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .environmentObject(ARData)
                .environmentObject(mapData)
                .onAppear {
                    locationManager.delegate = ARData
                    locationManager.requestWhenInUseAuthorization()
                    
                    if mapData.isToSrcBS {
                        ARData.getDirection(Source: mapData.region.center, Destination: mapData.busSrcCoord)
                    } else if mapData.isToRealDes {
                        ARData.getDirection(Source: mapData.region.center, Destination: mapData.realDesCoord)
                    }
                }
            
            VStack(spacing: 0) {
                HStack {
                    if !ARData.routeInstruction.isEmpty {
                        Text("\(ARData.routeInstruction[ARData.closestRouteCoordIndex])")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    } else {
                        Text("--")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    Text("\(ARData.newDesETA<mapData.formattedETA ? "🚶" : "🏃‍♂️") \(ARData.newDesETA) min")
                        .foregroundColor(ARData.newDesETA<mapData.formattedETA || matchRouteInfo.chosenRoute[0].srcRS.routeStop.route=="MTR" ? Color.white : Color.red)
                        .padding()
                }
                .background(Color.gray.opacity(0.5))
                .padding()
                
                Spacer()
                
                ARMapView()
                    .environmentObject(ARData)
                    .frame(height: 200)
                    .clipShape(SemiCircle())
            }
        }
    }
}

struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            path.addArc(center: CGPoint(x: rect.width/2, y: 200), radius: rect.width/2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            path.closeSubpath()
        }
        return path
    }
}
