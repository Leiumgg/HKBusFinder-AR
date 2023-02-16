//
//  RouteStopInfo.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 12/2/2023.
//

import Foundation

struct seqStopInfo: Hashable, Codable {
    var seq: Int
    var stopInfo: stopResult
}
