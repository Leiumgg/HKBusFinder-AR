//
//  Home.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import SwiftUI
import CoreLocation

struct Home: View {
    // Create MapViewModel
    @StateObject var mapData = HomeMapViewModel()
    // Location Manager
    @State var locationManager = CLLocationManager()
    
    // Set matchRouteInfo as Observed Object
    @ObservedObject var matchRouteInfo = MatchRouteInfo()
    
    // Slider Status and Value
    @State private var showDistanceBar = false
    @State private var walkingDistance = 300.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MapView
                HomeMapView()
                    // mapData as environmentObject -> use in subView
                    .environmentObject(mapData)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture {
                        withAnimation {
                            showDistanceBar = false
                        }
                    }
                
                // Search Route Button
                VStack {
                    Spacer()
                    
                    // Navigate to Routes-Stops View
                    NavigationLink(destination: RoutesSelect(matchRouteInfo: matchRouteInfo)) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.primary)
                            Text("Routes")
                                .foregroundColor(.primary)
                        }
                        .frame(width: 125, height: 45)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .disabled(mapData.selectedPlace.isEmpty)
                    .opacity(mapData.selectedPlace.isEmpty ? 0: 1)
                    .padding()
                }
                
                VStack {
                    //Search Bar
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search", text: $mapData.searchTxt)
                                .colorScheme(.light)
                            
                            Button {
                                mapData.searchTxt = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.white)
                        
                        // Displaying Results
                        if !mapData.places.isEmpty && mapData.searchTxt != "" {
                            ScrollView {
                                VStack(spacing: 15) {
                                    ForEach(mapData.places) { place in
                                        Text(place.placemark.name ?? "")
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading)
                                            .onTapGesture {
                                                mapData.selectPlace(place: place)
                                                
                                                // Dismiss Keyboard
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                
                                                // Set the busStopNearby
                                                matchRouteInfo.desCoord = place.placemark.location!.coordinate
                                                matchRouteInfo.srcCoord = mapData.region.center
                                            }
                                        
                                        Divider()
                                    }
                                }
                                .padding(.top)
                            }
                            .background(Color.white)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Button View
                    VStack {
                        Button(action: mapData.focusLocation) {
                            Image(systemName: "scope")
                                .font(.system(size: 25))
                                .padding(10)
                                .background(Color.primary)
                                .clipShape(Circle())
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .bottomTrailing)
                        
                        HStack {
                            if showDistanceBar {
                                ZStack {
                                    VStack(spacing: 0) {
                                        Slider(value: $walkingDistance, in: 50...1000, step: 50.0)
                                            .onChange(of: walkingDistance, perform: { newValue in
                                                matchRouteInfo.walkDistance = newValue
                                            })
                                            .frame(width: 250)
                                        Text(String(format: "%.fm", walkingDistance))
                                            .foregroundColor(Color.blue)
                                    }
                                    .padding(.horizontal)
                                    .background(Color.primary)
                                    .clipShape(Capsule())
                                }
                                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                            } else {
                                Button {
                                    withAnimation {
                                        showDistanceBar = true
                                    }
                                } label: {
                                    Image(systemName: "figure.walk.circle")
                                        .font(.system(size: 30))
                                        .padding(10)
                                        .background(Color.primary)
                                        .clipShape(Circle())
                                }
                                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                            }
                            
                            Button(action: mapData.updateMapType) {
                                Image(systemName: mapData.mapType == .standard ? "network" : "map")
                                    .font(.system(size: 30))
                                    .padding(10)
                                    .background(Color.primary)
                                    .clipShape(Circle())
                            }
                            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                // Setting Delegate
                locationManager.delegate = mapData
                locationManager.requestWhenInUseAuthorization()
                
                // Load Buses and Rotues Data From JSON URL
                matchRouteInfo.loadStopsData()
                matchRouteInfo.loadRouteStopsData()
            }
            // Permission Denied Alert
            .alert(isPresented: $mapData.permissionDenied) {
                Alert(title: Text("Permission Denied"), message: Text("Please Enable Permission In App Settings"), dismissButton: .default(Text("Go to Settings"), action: {
                    // Redirecting User to Settings
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
            }
            .onChange(of: mapData.searchTxt) { (value) in
                // Searching Places
                let delay = 0.2
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if value == mapData.searchTxt {
                        // Search
                        self.mapData.searchQuery()
                    }
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
