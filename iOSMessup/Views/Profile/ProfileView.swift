//
//  ProfileView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.authVM) private var authVM: AuthenticationModelProtocol
    private var userImage: String = ""
    private var userName: String = ""
    private var userEmail: String = ""

    var body: some View {
        VStack(spacing: MUSpacer.size06) {
            Image(userImage.isEmpty ? "logoImage" : userImage)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.mint)
                .padding(.top, 32)
            Text(userName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(primaryText)
            Text(userEmail)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()
                .padding(.horizontal)

            VStack(spacing: 16) {
                ProfileRow(icon: "gearshape.fill", title: "Configuración")
                ProfileRow(icon: "bell.fill", title: "Notificaciones")
                ProfileRow(icon: "shield.lefthalf.filled", title: "Privacidad")
            }

            Spacer()

            Button {
                Task{ try await authVM.logout() }
            } label: {
                Text("Cerrar sesión")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mint)
                    .cornerRadius(12)
                    .font(.headline)
            }
            .padding(.bottom)
        }
        .padding()
        .background(backgroundColor.ignoresSafeArea())
    }

    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.mint)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView()
}
