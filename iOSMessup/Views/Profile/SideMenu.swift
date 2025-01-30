//
//  SideMenu.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isShowing: Bool
    var edgeTransition: AnyTransition = .move(edge: .leading)

    var body: some View {
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing = false
                    }
                SideMenuContentView()
                    .padding(.top, 40)
                    .transition(edgeTransition)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .toolbar(isShowing ? .hidden : .visible, for: .navigationBar)
        .toolbar(isShowing ? .hidden : .visible, for: .tabBar)
        .animation(.easeInOut, value: isShowing)
    }
}

#Preview {
    @Previewable @State var isShowing = true
    SideMenu(isShowing: $isShowing)
}
