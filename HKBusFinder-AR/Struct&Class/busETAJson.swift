//
//  busETAJson.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 22/2/2023.
//

import Foundation

struct etaResponse: Codable {
    var data: [etaResult]
}

struct etaResult: Hashable, Codable {
    var route: String
    var dir:String
    var service_type: Int
    var seq: Int
    var eta_seq: Int
    var eta: String
    var rmk_en: String
}
