//
//  NothingView.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 29/1/2023.
//

import SwiftUI

class Counter: ObservableObject {
    @Published var count = 0 {
        didSet {zeroit()}
    }
    
    func zeroit() {
        if count > 20 {
            count = 0
        }
    }
}

struct NothingView: View {
    @ObservedObject var counter = Counter()
    var body: some View {
        VStack {
            Text("Count: \(counter.count)")
            CounterView(counter: counter)
        }
        .onAppear{print("nothing onappear")}
    }
}

struct CounterView: View {
    @ObservedObject var counter: Counter

    var body: some View {
        VStack {
            Button(action: {
                self.counter.count += 1
            }) {
                Text("Increase Count").onAppear{print("Button on appear")}
            }
            Text("subview counter: \(counter.count)")
        }
    }
}

struct NothingView_Previews: PreviewProvider {
    static var previews: some View {
        NothingView()
    }
}
