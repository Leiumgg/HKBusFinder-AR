//
//  RouteStopsJson.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/1/2023.
//

import Foundation
import CoreLocation

struct routeResponse: Codable{
    var data: [routeResult]
}

struct routeResult: Hashable, Codable {
    var route: String
    var bound: String
    var service_type: String
    var seq: String
    var stop: String
}
