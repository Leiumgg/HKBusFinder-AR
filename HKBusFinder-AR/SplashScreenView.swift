//
//  SplashScreenView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 2/4/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                VStack {
                    VStack{
                        Image("appstore")
                            .resizable()
                            .frame(width: 150, height: 150)
                        
                        Text("BUSiFIND-AR")
                            .font(.title)
                            .fontWeight(.heavy)
                    }
                    .frame(maxHeight: .infinity)
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.8)) {
                            self.size = 1
                            self.opacity = 1.0
                        }
                    }
                    
                    Text("Point-to-Point Route")
                        .fontWeight(.bold)
                        
                    Text("AR Direction Guide")
                        .fontWeight(.bold)
                    
                    Text("User-Friendly Interface")
                        .fontWeight(.bold)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
