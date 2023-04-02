//
//  NothingView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/1/2023.
//

import SwiftUI

struct NothingView: View {
    @State private var showSrcSheet = false
    @State private var showDesSheet = false
    
    var body: some View {
        VStack {
            Text("Barnes will tear you apart AGAIN!")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                VStack(alignment: .trailing) {
                    Button {
                        showSrcSheet.toggle()
                    } label: {
                        Text("Search Source Location")
                    }
                    .sheet(isPresented: $showSrcSheet) {
                        VStack {
                            Text("Search Text")
                            Text("Scroll view of search result")
                        }
                    }
                    
                    Button {
                        showDesSheet.toggle()
                    } label: {
                        Text("Search Destination Location")
                    }
                    .sheet(isPresented: $showDesSheet) {
                        VStack {
                            Text("Search Text")
                            Text("Scroll view of search result")
                        }
                    }
                }
            }
        }
    }
}

struct NothingView_Previews: PreviewProvider {
    static var previews: some View {
        NothingView()
    }
}
