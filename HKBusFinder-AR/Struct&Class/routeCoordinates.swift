//
//  routeCoordinates.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import Foundation
import SwiftUI
import MapKit

public extension MKMultiPoint {
    // route.polyline.coordinates
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
