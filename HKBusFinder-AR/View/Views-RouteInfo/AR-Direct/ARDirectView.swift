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
            
            VStack {
                Spacer()
                ARMapView()
                    .environmentObject(ARData)
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .clipShape(SemiCircle())
            }
        }
    }
}

struct ARDirectView_Previews: PreviewProvider {
    static var previews: some View {
        testttView()
    }
}
struct testttView: View {
    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(Color.blue)
                .frame(width: UIScreen.main.bounds.width, height: 200)
                .clipShape(SemiCircle())
        }
    }
}

struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path { path in
            path.addArc(center: CGPoint(x: rect.width/2, y: rect.height), radius: rect.width/2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            path.closeSubpath()
        }
        return path
    }
}
