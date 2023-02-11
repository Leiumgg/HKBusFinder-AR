//
//  Place.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 28/1/2023.
//

import Foundation
import SwiftUI
import MapKit

struct Place: Identifiable {
    
    var id = UUID().uuidString
    var placemark: CLPlacemark
    
}
