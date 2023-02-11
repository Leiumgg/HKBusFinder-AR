//
//  Nothing2View.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 5/2/2023.
//

import SwiftUI

struct Nothing2View: View {
    @State private var frameHeight: CGFloat = 400

    var body: some View {
        VStack(spacing: 0){
            Color(.systemBlue)
                .frame(height: frameHeight)
            ZStack {
                Color(.systemRed)
                Button("change frame") {
                    withAnimation {
                        if frameHeight == 400 {
                            frameHeight = 600
                        } else {
                            frameHeight = 400
                        }
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .all)
        }
    }
}

struct Nothing2View_Previews: PreviewProvider {
    static var previews: some View {
        Nothing2View()
    }
}
