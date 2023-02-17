//
//  NothingView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/1/2023.
//

import SwiftUI

struct NothingView: View {
    var body: some View {
        TabView {
           FirstTabView()
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Directions")
                }
            
            SecondTabView()
                .tabItem {
                    Image(systemName: "bus")
                    Text("On Bus")
                }
            
            ThirdTabView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("To Stop")
                }
        }
    }
}

struct FirstTabView: View {
    var body: some View {
        Color(.black)
    }
}

struct SecondTabView: View {
    var body: some View {
        Text("This is the second tab view")
    }
}

struct ThirdTabView: View {
    var body: some View {
        Text("This is the third tab view")
    }
}


struct NothingView_Previews: PreviewProvider {
    static var previews: some View {
        NothingView()
    }
}
