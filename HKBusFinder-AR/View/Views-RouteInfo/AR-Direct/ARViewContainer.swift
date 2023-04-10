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
        uiView.scene.anchors.removeAll()
        let anchor = AnchorEntity()
        let material = SimpleMaterial(color: .red, isMetallic: false)
        
        var lastNodePosition = [SIMD3<Float>]()
        
        for i in 0 ..< ARData.routeCoordinates.count {
            let endPoint = calEntityPos(entityCoord: ARData.routeCoordinates[i])
            if !lastNodePosition.isEmpty {
                let startPoint = lastNodePosition[0]
                
                let length = simd_distance(startPoint, endPoint)
                let direction = (endPoint - startPoint) / length
                
                let lineMesh = MeshResource.generatePlane(width: 1, depth: length)
                
                let lineEntity = ModelEntity(mesh: lineMesh, materials: [material])
                lineEntity.position = startPoint + direction * length / 2
                lineEntity.orientation = simd_quatf(from: [0,0,-1], to: direction)
                
                anchor.addChild(lineEntity)
            }
            
            lastNodePosition = [endPoint]
        }
        
        uiView.scene.addAnchor(anchor)
    }
    
    func calEntityPos(entityCoord: CLLocationCoordinate2D) -> SIMD3<Float> {
        let userLocation = CLLocation(latitude: ARData.region.center.latitude, longitude: ARData.region.center.longitude)
        let entityLocation = CLLocation(latitude: entityCoord.latitude, longitude: entityCoord.longitude)
        
        //Calculate distance of entity from user
        let distance = entityLocation.distance(from: userLocation)
        
        //Calculate angle from North
        let xATAN2 = cos(entityLocation.coordinate.latitude) * sin(userLocation.coordinate.longitude - entityLocation.coordinate.longitude)
        let yATAN2 = cos(userLocation.coordinate.latitude) * sin(entityLocation.coordinate.latitude) - sin(userLocation.coordinate.latitude) * cos(entityLocation.coordinate.latitude) * cos(userLocation.coordinate.longitude - entityLocation.coordinate.longitude)
        let angle = atan2(xATAN2, yATAN2)
        
        //+x: East, +y: up, -z: North
        let x = Float((distance * sin(angle))-2)
        let z = Float(-(distance * cos(angle)))
        
        return [x,-10,z]
    }
    
}
