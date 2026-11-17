//
//  ProfileView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

// MARK: - ProfileRoute

private enum ProfileRoute: Hashable {
    case exportToSVG
    case manageCategories
    case changeCurrency
    case manageSubscriptions

    @ViewBuilder
    var destination: some View {
        switch self {
        case .exportToSVG: Text("Export to SVG")
        case .manageCategories: Text("Manage Categories")
        case .changeCurrency: Text("Change Currency")
        case .manageSubscriptions: Text("Manage subscriptions")
        }
    }
}

struct ProfileView: View {
    @AppStorage("MUBiometryEnabled") private var enableBiometry = true

    var body: some View {
        NavigationStack {
            List {
                UserAccountSection()
                AppActionsSection(enableBiometry: $enableBiometry)
                AdditionalToolsSection()
                SupportSection()
                #if DEBUG
                DebugSection()
                #endif
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Settings")
            .navigationDestination(for: ProfileRoute.self) { $0.destination }
        }
    }
}


#Preview {
    ProfileView()
}

// MARK: - View Components

private struct SupportSection: View {
    var body: some View {
        Section("Support") {
            Link(destination: URL(string: "apple.com")!) {
                Label("Contact us", systemImage:"envelope")
            }
            Link(destination: URL(string: "apple.com")!) {
                Label("Donations and Support", systemImage:"heart.fill")
            }
        }
    }
}

private struct AdditionalToolsSection: View {
    var body: some View {
        Section("Additional tools") {
            NavigationLink(value: ProfileRoute.exportToSVG) {
                Label("Export to SVG", systemImage:"square.and.arrow.up")
            }
        }
    }
}

private struct AppActionsSection: View {
    @Binding var enableBiometry: Bool

    var body: some View {
        Section("App actions") {
            Toggle(isOn: $enableBiometry) {
                Label("Enable Biometry", systemImage:"faceid")
            }
            NavigationLink(value: ProfileRoute.manageCategories) {
                Label("Manage Categories", systemImage:"folder.badge.gearshape")
            }
            NavigationLink(value: ProfileRoute.changeCurrency) {
                Label("Change Currency", systemImage:"dollarsign")
            }
        }
    }
}

private struct UserAccountSection: View {
    var body: some View {
        Section("User account") {
            NavigationLink(value: ProfileRoute.manageSubscriptions) {
                Label("Manage subscriptions", systemImage:"star.fill")
            }
        }
    }
}
