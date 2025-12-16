//
//  ProfileView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.authenticationService) var authenticationService
    @AppStorage("MUBiometryEnabled") private var enableBiometry = true

    var body: some View {
        NavigationStack {
            List {
                UserAccountSection()
                AppActionsSection(enableBiometry: $enableBiometry)
                AdditionalToolsSection()
                SupportSection()
                LogOutSection(authenticationService: authenticationService)
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Settings")
        }
    }
}


#Preview {
    ProfileView()
}

// MARK: - View Components

struct LogOutSection: View {

    let authenticationService: AuthenticationService

    var body: some View {
        Section {
            Button(role: .destructive) {
                authenticationService.logout()
            } label: {
                Label("Log out", systemImage:"power")
                    .foregroundColor(.red)
            }
        }
    }
}

struct SupportSection: View {
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

struct AdditionalToolsSection: View {
    var body: some View {
        Section("Additional tools") {
            NavigationLink(destination: Text("Export to SVG")) {
                Label("Export to SVG", systemImage:"square.and.arrow.up")
            }
        }
    }
}

struct AppActionsSection: View {
    @Binding var enableBiometry: Bool

    var body: some View {
        Section("App actions") {
            Toggle(isOn: $enableBiometry) {
                Label("Enable Biometry", systemImage:"faceid")
            }
            NavigationLink(destination: Text("Manage Categories")) {
                Label("Manage Categories", systemImage:"folder.badge.gearshape")
            }
            NavigationLink(destination: Text("Change Currency")) {
                Label("Change Currency", systemImage:"dollarsign")
            }
        }
    }
}

struct UserAccountSection: View {
    var body: some View {
        Section("User account") {
            NavigationLink(destination: Text("Change password")) {
                Label("Change Password", systemImage:"lock.rotation")
            }
            NavigationLink(destination: Text("Change password")) {
                Label("Manage subscriptions", systemImage:"star.fill")
            }
        }
    }
}
