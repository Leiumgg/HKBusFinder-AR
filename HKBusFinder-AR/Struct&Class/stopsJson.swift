//
//  stopsJson.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/1/2023.
//

import Foundation

struct stopResponse: Codable {
    var data: [stopResult]
}

struct stopResult: Hashable, Codable {
    var stop: String
    var name_en:String
    var lat: String
    var long: String
}
