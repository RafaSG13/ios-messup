//
//  ProfileView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @State private var selectedRow: ProfileRowModel?
    @Environment(\.authVM) var authVM: AuthenticationModelProtocol

    var body: some View {
        NavigationStack {
            VStack {
                ProfileHeader()
                .padding()
                .frame(height: 130)

                List(ProfileRowModel.allCases, id: \.self) { row in
                    Button {
                        selectedRow = row
                    } label: {
                        ProfileRow(model: row)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
                    .onChange(of: selectedRow) { _, newValue in
                        if selectedRow == .logOut {
                            Task {
                                try await authVM.logout()
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - ProfileHeader

fileprivate struct ProfileHeader: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.15))
                .stroke(.accent.opacity(0.15), style: .init())
            HStack {
                Image("logoImage")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.gray)
                    .clipShape(.circle)
                    .padding(.leading, MUSpacer.size04)
                    .padding(.trailing, MUSpacer.size04)

                VStack(alignment: .leading, spacing: 5) {
                    Text("John Doe")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Edit Profile")
                        .font(.subheadline)
                        .underline()
                        .foregroundColor(.blue)
                        .onTapGesture {
                            // Acción para editar perfil
                        }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ProfileView()
}
