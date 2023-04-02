//
//  Home.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import SwiftUI
import CoreLocation
import MapKit

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
    
    // Search Sheet
    @State private var showSrcSheet = false
    @State private var showDesSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Search Buttons and Search Sheets
                HStack {
                    VStack(spacing: 5) {
                        // Source Search
                        HStack {
                            Text("From")
                                .foregroundColor(.white)
                                .frame(alignment: .leading)
                                .padding(.leading)
                            
                            Button {
                                showSrcSheet.toggle()
                            } label: {
                                Text("\(mapData.selectedSrcPlace.isEmpty ? "Current Location" : mapData.selectedSrcPlace[0].title!)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .colorScheme(.dark)
                            .background(BlurView(style: .dark)
                                .clipShape(CustomCorner(corners: [.allCorners], radius: 10))
                            )
                            .sheet(isPresented: $showSrcSheet) {
                                VStack(spacing: 0) {
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: 80, height: 4)
                                        .padding(.bottom)
                                    
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white)
                                        
                                        TextField("Search", text: $mapData.searchTxt)
                                            .foregroundColor(.white)
                                        
                                        Button {
                                            mapData.searchTxt = ""
                                            mapData.clearSrcSearch()
                                            matchRouteInfo.srcCoord = mapData.region.center
                                            matchRouteInfo.busStopNearby()
                                            mapData.mapView.removeAnnotations(matchRouteInfo.desStopsPin)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(Color(UIColor.darkGray))
                                    
                                    // Displaying Results
                                    if !mapData.places.isEmpty && mapData.searchTxt != "" {
                                        ScrollView {
                                            VStack(spacing: 15) {
                                                ForEach(mapData.places) { place in
                                                    Text(place.placemark.name ?? "")
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding(.leading)
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            mapData.selectSrcPlace(place: place)
                                                            
                                                            // Dismiss Keyboard
                                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                            
                                                            // Set the busStopNearby
                                                            mapData.mapView.removeAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                                                            matchRouteInfo.srcCoord = place.placemark.location!.coordinate
                                                            matchRouteInfo.busStopNearby()
                                                            mapData.mapView.addAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                                                            
                                                            // Dismiss Sheet
                                                            showSrcSheet.toggle()
                                                        }
                                                    
                                                    Divider()
                                                }
                                            }
                                            .padding(.top)
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .presentationDetents([.medium])
                            }
                        }
                        .padding(.top)
                        
                        Divider()
                        
                        // Destination Search
                        HStack {
                            Text("  To   ")
                                .foregroundColor(.white)
                                .frame(alignment: .leading)
                                .padding(.leading)
                            
                            Button {
                                showDesSheet.toggle()
                            } label: {
                                if mapData.selectedDesPlace.isEmpty {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                        Text("Search Destination")
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                } else {
                                    Text("\(mapData.selectedDesPlace[0].title!)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .colorScheme(.dark)
                            .background(BlurView(style: .dark)
                                .clipShape(CustomCorner(corners: [.allCorners], radius: 10))
                            )
                            .sheet(isPresented: $showDesSheet) {
                                VStack(spacing: 0) {
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: 80, height: 4)
                                        .padding(.bottom)
                                    
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white)
                                        
                                        TextField("Search", text: $mapData.searchTxt)
                                            .foregroundColor(.white)
                                        
                                        Button {
                                            mapData.searchTxt = ""
                                            mapData.clearDesSearch()
                                            mapData.mapView.removeAnnotations(matchRouteInfo.desStopsPin)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(Color(UIColor.darkGray))
                                    
                                    // Displaying Results
                                    if !mapData.places.isEmpty && mapData.searchTxt != "" {
                                        ScrollView {
                                            VStack(spacing: 15) {
                                                ForEach(mapData.places) { place in
                                                    Text(place.placemark.name ?? "")
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding(.leading)
                                                        .contentShape(Rectangle())
                                                        .onTapGesture {
                                                            mapData.selectDesPlace(place: place)
                                                            
                                                            // Dismiss Keyboard
                                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                            
                                                            // Set the busStopNearby
                                                            mapData.mapView.removeAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                                                            matchRouteInfo.desCoord = place.placemark.location!.coordinate
                                                            matchRouteInfo.busStopNearby()
                                                            mapData.mapView.addAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                                                            
                                                            // Dismiss Sheet
                                                            showDesSheet.toggle()
                                                        }
                                                    
                                                    Divider()
                                                }
                                            }
                                            .padding(.top)
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .presentationDetents([.medium])
                            }
                        }
                        .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        mapData.clearAllSearch()
                        mapData.mapView.removeAnnotations(matchRouteInfo.srcStopsPin)
                        matchRouteInfo.srcCoord = mapData.region.center
                        mapData.mapView.removeAnnotations(matchRouteInfo.desStopsPin)
                        matchRouteInfo.busStopNearby()
                        mapData.mapView.addAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing)
                }
                
                ZStack {
                    // MapView
                    HomeMapView()
                        .environmentObject(mapData)
                        .ignoresSafeArea(.all, edges: .bottom)
                        .onTapGesture {
                            withAnimation {
                                showDistanceBar = false
                            }
                        }
                    
                    VStack {
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
                                            Slider(value: $walkingDistance, in: 50...800, step: 50.0)
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
                        .offset(y: -100)
                        .padding(.horizontal)
                    }
                    
                    // Bottom Sheet
                    GeometryReader { proxy -> AnyView in
                        let height = proxy.frame(in: .global).height
                        return AnyView(HomeSheetView(height: height, matchRouteInfo: matchRouteInfo).environmentObject(mapData))
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
                .onAppear {
                    // Setting Delegate
                    locationManager.delegate = mapData
                    locationManager.requestWhenInUseAuthorization()
                    
                    // Load Buses and Rotues Data From JSON URL
                    matchRouteInfo.loadStopsData()
                    matchRouteInfo.loadRouteStopsData()
                }
                // Get BusStopNearby
                .onChange(of: matchRouteInfo.allStops.count, perform: { newValue in
                    mapData.mapView.removeAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                    if mapData.selectedSrcPlace.isEmpty {
                        matchRouteInfo.srcCoord = mapData.region.center
                    }
                    matchRouteInfo.busStopNearby()
                    mapData.mapView.addAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                })
                // Get BusStopNearby
                .onChange(of: mapData.hasSetRegion, perform: { newValue in
                    mapData.mapView.removeAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                    if mapData.selectedSrcPlace.isEmpty {
                        matchRouteInfo.srcCoord = mapData.region.center
                    }
                    matchRouteInfo.busStopNearby()
                    mapData.mapView.addAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                })
                // Get BusStopNearby
                .onChange(of: walkingDistance, perform: { newValue in
                    mapData.mapView.removeAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                    if mapData.selectedSrcPlace.isEmpty {
                        matchRouteInfo.srcCoord = mapData.region.center
                    }
                    matchRouteInfo.busStopNearby()
                    mapData.mapView.addAnnotations(matchRouteInfo.srcStopsPin + matchRouteInfo.desStopsPin)
                })
                // Permission Denied Alert
                .alert(isPresented: $mapData.permissionDenied) {
                    Alert(title: Text("Permission Denied"), message: Text("Please Enable Permission In App Settings"), dismissButton: .default(Text("Go to Settings"), action: {
                        // Redirecting User to Settings
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                }
                // Searching Places
                .onChange(of: mapData.searchTxt) { (value) in
                    let delay = 0.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        if value == mapData.searchTxt {
                            self.mapData.searchQuery()
                        }
                    }
                }
            }
        }
    }
}
