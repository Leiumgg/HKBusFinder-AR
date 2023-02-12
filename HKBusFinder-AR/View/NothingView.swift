//
//  NothingView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/1/2023.
//

import SwiftUI

class Counter: ObservableObject {
    @Published var RSs = [routeResult]()
    
    func loadData(){
        RSs = [routeResult]()
        let route = "935"
        let bound = "outbound"
        let service_type = "2"
        guard let url = URL(string: "https://data.etabus.gov.hk/v1/transport/kmb/route-stop/\(route)/\(bound)/\(service_type)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { fdata, response, error in
            if let fdata = fdata {
                if let decodedResponse = try? JSONDecoder().decode(routeResponse.self, from: fdata) {
                    DispatchQueue.main.async {
                        self.RSs = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
        print("----------------------\(RSs.count)----------------------")
    }
}

struct NothingView: View {
    @ObservedObject var counter = Counter()
    var body: some View {
        VStack {
            NavigationLink {
                List(counter.RSs, id: \.self) { i in
                    Text("\(i.seq): \(i.stop)")
                }
            } label: {
                Text("sadfasdf")
            }

        }
        .onAppear{counter.loadData()}
    }
}

struct NothingView_Previews: PreviewProvider {
    static var previews: some View {
        NothingView()
    }
}
