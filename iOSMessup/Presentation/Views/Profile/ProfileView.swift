//
//  ProfileView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.authenticationService) var authenticationService
    @State private var notificationsEnabled = true
    var body: some View {
        NavigationStack {
            List {
                Section("User account") {
                    NavigationLink(destination: Text("Change password")) {
                        Label("Change Password", systemImage:"lock.rotation")
                    }
                    NavigationLink(destination: Text("Change password")) {
                        Label("Manage subscriptions", systemImage:"star.fill")
                    }
                }

                Section("App actions") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Enable Biometry", systemImage:"faceid")
                    }
                    NavigationLink(destination: Text("Change password")) {
                        Label("Manage Categories", systemImage:"folder.badge.gearshape")
                    }
                    NavigationLink(destination: Text("Change password")) {
                        Label("Change Currency", systemImage:"dollarsign")
                    }
                }

                Section("Additional tools") {
                    NavigationLink(destination: Text("Change password")) {
                        Label("Export to SVG", systemImage:"square.and.arrow.up")
                    }
                }

                Section("Support") {
                    Link(destination: URL(string: "apple.com")!) {
                        Label("Contact us", systemImage:"envelope")
                    }
                    Link(destination: URL(string: "apple.com")!) {
                        Label("Donations and Support", systemImage:"heart.fill")
                    }
                }

                Section { // Colocar el botón en su propia sección mejora el diseño
                    Button(role: .destructive) {
                        authenticationService.logout()
                    } label: {
                        Label("Log out", systemImage:"power")
                            .foregroundColor(.red)
                    }
                }

            }
            .navigationTitle("Settings")
        }
    }
}


#Preview {
    ProfileView()
}
