//
//  Nothing2View.swift
//  HKBusFinder-AR
//
//  Created by John Leung on 5/2/2023.
//

import SwiftUI

struct Nothing2View: View {
    // For Sheet
    @State var searchText = ""
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    @State private var isShowingDetailView = false

    var body: some View {
        ZStack {
            // Main View
            ZStack {
                
                Color.red
                VStack {
                    Spacer()
                    Button("Show Detail View") {
                        withAnimation {
                            isShowingDetailView = true
                        }
                    }
                    Spacer()
                    if isShowingDetailView {
                        DetailView(isPresented: $isShowingDetailView)
                    }
                }
            }
            //.offset(y: -100)
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Bottom Sheet
            // For Getting Height of Drag Gesture
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                
                return AnyView(
                    ZStack {
                        
                        BlurView(style: .systemThinMaterialDark)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                        
                        VStack {
                            
                            VStack {
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 4)
                                    //.padding(.top)
                                
                                TextField("Search", text: $searchText)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(BlurView(style: .dark))
                                    .cornerRadius(10)
                                    .colorScheme(.dark)
                                    .padding(.top, 10)
                            }
                            .frame(height: 100)
                            
                            // ScrollView Content
                            ScrollView(.vertical, showsIndicators: false) {
                                BottomContent()
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .offset(y: height - 100)
                    .offset(y: -offset > 0 ? -offset <= (height-100) ? offset : -(height-100) : 0)
                    .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.height
                        onChange()
                    }).onEnded({ value in
                        let maxHeight = height - 100
                        withAnimation {
                            // Logical Condition, medium, full screen ...
                            if -offset > 100 && -offset < maxHeight/2 {
                                // Mid
                                offset = -(maxHeight/3)
                            } else if -offset > maxHeight/2 {
                                // Full
                                offset = -maxHeight
                            } else {
                                offset = 0
                            }
                        }
                        // Store last offset
                        lastOffset = offset
                    }))
                )
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
    
    func getBlurRadius() -> CGFloat {
        let progress = -offset / (UIScreen.main.bounds.height - 100)
        
        return progress * 30
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

struct BottomContent: View {
    var body: some View {
        VStack {
            HStack {
                Text("Favourites")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 20)
            
            Divider()
                .background(Color.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            Image(systemName: "house.fill")
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(BlurView(style: .dark))
                                .clipShape(Circle())
                        }
                        
                        Text("Home")
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            Image(systemName: "house.fill")
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(BlurView(style: .dark))
                                .clipShape(Circle())
                        }
                        
                        Text("Home")
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            Image(systemName: "house.fill")
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(BlurView(style: .dark))
                                .clipShape(Circle())
                        }
                        
                        Text("Home")
                            .foregroundColor(.white)
                    }
                    
                }
            }
            .padding(.top)
            
            HStack {
                Text("Editor's Pick")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 25)
            
            Divider()
                .background(Color.white)
            
            ForEach(1...6, id: \.self) { index in
                Image(systemName: "circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width-30, height: 250)
                    .cornerRadius(15)
                    .padding(.top)
            }
        }
    }
}

struct Nothing2View_Previews: PreviewProvider {
    static var previews: some View {
        Nothing2View()
    }
}
