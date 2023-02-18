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
        VStack {
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
            
            ARMapView()
                .environmentObject(ARData)
                .frame(height: 200)
        }
    }
}

struct ARDirectView_Previews: PreviewProvider {
    static var previews: some View {
        ARDirectView()
    }
}
