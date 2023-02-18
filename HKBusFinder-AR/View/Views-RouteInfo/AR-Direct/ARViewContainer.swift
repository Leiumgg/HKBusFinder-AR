//
//  ARViewController.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import SwiftUI
import RealityKit
import ARKit
import MapKit

struct ARViewContainer: UIViewRepresentable {
    // PASS DATA TO ARMapViewModel
    @EnvironmentObject var ARData: ARMapViewModel
    @EnvironmentObject var mapData: DirectionsMapViewModel
    
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        let session = view.session
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        config.planeDetection = .horizontal
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        session.run(config)
        
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        updateARRouteSign(uiView: uiView)
    }
    
    func updateARRouteSign(uiView: ARView) {
        print("+++++++++++++++++++++++++++++++++++++++++++++++++")
        uiView.scene.anchors.removeAll()
        let anchor = AnchorEntity()
        let color = UIColor.systemBlue
        let shader = SimpleMaterial(color: color, isMetallic: true)
        
        for i in ARData.closestRouteCoordinateIndex-2..<ARData.closestRouteCoordinateIndex+3 {
            if (i >= 0) && (i < ARData.routeCoordinates.count) {
                let text = MeshResource.generateText("Step \(i)", extrusionDepth: 0.5, font: .systemFont(ofSize: 5))
                let textEntity = ModelEntity(mesh: text, materials: [shader])
                
                textEntity.position = calculateEntityPosition(entityCoordinate: ARData.routeCoordinates[i])
                anchor.addChild(textEntity)
            }
        }
        uiView.scene.addAnchor(anchor)
    }
    
    func calculateEntityPosition(entityCoordinate: CLLocationCoordinate2D) -> SIMD3<Float> {
        let userLocation = CLLocation(latitude: ARData.region.center.latitude, longitude: ARData.region.center.longitude)
        let entityLocation = CLLocation(latitude: entityCoordinate.latitude, longitude: entityCoordinate.longitude)
        
        //Calculate distance of entity from user
        let distance = entityLocation.distance(from: userLocation)
        
        //Calculate angle from North
        let xATAN2 = cos(entityLocation.coordinate.latitude) * sin(userLocation.coordinate.longitude - entityLocation.coordinate.longitude)
        let yATAN2 = cos(userLocation.coordinate.latitude) * sin(entityLocation.coordinate.latitude) - sin(userLocation.coordinate.latitude) * cos(entityLocation.coordinate.latitude) * cos(userLocation.coordinate.longitude - entityLocation.coordinate.longitude)
        let angle = atan2(xATAN2, yATAN2)
        print("Angle: \(angle*180/Double.pi)")
        
        //+x: East, +y: up, -z: North
        let x = Float((distance * sin(angle))-2)
        let z = Float(-(distance * cos(angle)))
        print("X-Coordinate: \(x)")
        print("Z-Coordinate: \(z)")
        
        return [x,-5,z]
    }
    
}
