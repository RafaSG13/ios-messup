//
//  HideTabBarAfterScrollingThreshold.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 25/1/25.
//

import SwiftUI

//TODO: WIP - This is not working yet, better way to hide the tab bar when scrolling down and show it when stopping scrolling

@available(iOS 18.0, *)
struct HideTabBarAfterScrollingThreshold: ViewModifier {
    @State private var lastOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    @State private var shouldHideTabBar = false
    @State var scrollThreshold: CGFloat
    @State private var timer: Timer?
    
    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Bool.self) { proxy in
                shouldHideTabBar(offset: proxy.contentOffset.y)
            } action: { _, newValue in
                guard newValue == true else { return }
                shouldHideTabBar = true
            }
            .onScrollPhaseChange({ oldPhase, newPhase in
                if newPhase.isScrolling == false {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        withAnimation(.easeIn) {
                            shouldHideTabBar = false
                        }
                    }
                }
            })
            .toolbarVisibility(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    
    func shouldHideTabBar(offset: CGFloat) -> Bool {
        currentOffset = offset
        let result = abs(currentOffset - lastOffset) > 20
        print(abs(currentOffset - lastOffset))
        lastOffset = currentOffset
        return result
    }
        
}

@available(iOS 18.0, *)
extension View {
    fileprivate func hideTabBarAfterScrollingThresholdBETA(threshold: CGFloat) -> some View {
        self.modifier(HideTabBarAfterScrollingThreshold(scrollThreshold: threshold))
    }
}
