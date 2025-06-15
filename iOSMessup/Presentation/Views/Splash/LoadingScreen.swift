//
//  LoadingScreen.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

struct LoadingScreen: View {
    @State private var loadingText: [String] = "Loading Messup...".map { String($0) }
    @State private var counter = 0
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    private let colors: [Color] = [.red, .yellow, .orange, .purple, .pink, .green, .blue]
    
    var body: some View {
        ZStack{
            Color.mintAccent.ignoresSafeArea()
            VStack(spacing: 40) {
                Image("logoImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)

                HStack(spacing: 0) {
                    ForEach(loadingText.indices, id: \.self) { index in
                        Text(loadingText[index])
                            .font(.largeTitle)
                            .foregroundStyle(counter == index ? colors.randomElement() ?? .teal : .white)
                            .fontWeight(.black)
                            .offset(y: counter == index ? -5 : 0)
                            .animation(.spring(), value: counter == index)
                    }
                }
            }
            .onReceive(timer) { _ in
                counter = (counter + 1) % loadingText.count
            }
        }
    }
}


    
    
    #Preview {
        LoadingScreen()
    }
