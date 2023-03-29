//
//  mtrStations.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/3/2023.
//

import Foundation

struct mtrStation: Hashable, Codable {
    var id: String
    var name: String
    var lat: String
    var long: String
    
    static let allStations: [mtrStation] = Bundle.main.decode(file: "mtrStationsCoord.json")
}

typealias EtaResponse = [mtrStation]

extension Bundle {
    func decode<T: Decodable>(file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file) in the project")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) in the project")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedData = try? decoder.decode(T.self, from: data) else {
            fatalError("Could not decode \(file) in the project")
        }
        
        return loadedData
    }
}
