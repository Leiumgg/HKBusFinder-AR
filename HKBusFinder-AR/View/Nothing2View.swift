//
//  Nothing2View.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 5/2/2023.
//

import SwiftUI

struct Nothing2View: View {
    @State private var isShowingDetailView = false

    var body: some View {
        ZStack {
            Color.red
            VStack {
                Spacer()
                Button("Show Detail View") {
                    isShowingDetailView = true
                }
                Spacer()
                if isShowingDetailView {
                    DetailView(isPresented: $isShowingDetailView)
                }
            }
        }
    }
}

struct DetailView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.gray
            VStack {
                Text("Detail View")
                Button("Close") {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        }
        .frame(height: 400)
    }
}

struct Nothing2View_Previews: PreviewProvider {
    static var previews: some View {
        Nothing2View()
    }
}
