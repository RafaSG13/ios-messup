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

    var body: some View {
        NavigationStack {
            VStack {
                ProfileHeader()
                .padding()
                .frame(height: 150)

                List(ProfileRowModel.allCases, id: \.self) { row in
                    Button {
                        selectedRow = row
                    } label: {
                        ProfileRow(model: row)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
                    .onChange(of: selectedRow) { oldValue, newValue in
                        print("Selected row changed from \(oldValue?.title ?? "nil") to \(newValue?.title ?? "nil")")
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


#Preview {
    ProfileView()
}


struct ProfileHeader: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .infinity)
                .fill(.secondary.opacity(0.15))
            HStack {
                Image("logoImage")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .clipShape(.circle)
                    .padding(.leading, 25)
                    .padding(.trailing, 20)
                
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
