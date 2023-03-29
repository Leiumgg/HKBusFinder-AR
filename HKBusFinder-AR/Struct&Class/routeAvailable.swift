//
//  routeAvailable.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 1/2/2023.
//

import Foundation

struct arrRouteStop: Hashable, Codable {
    var routeStop: routeResult
    var Stop: stopResult
}

struct routeAvailable: Hashable, Codable {
    var srcRS: arrRouteStop
    var desRS: arrRouteStop
    var totalDistance: Double
}
