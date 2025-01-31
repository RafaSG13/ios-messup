//
//  ProfileView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 30/1/25.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // Profile Header
                VStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("John Doe")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Edit Profile")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            // Acción para editar perfil
                        }
                }
                .padding()
                
                // Settings List
                List {
                    ProfileRow(icon: "gearshape.fill", title: "Settings", color: .gray)
                    ProfileRow(icon: "lock.fill", title: "Change Password", color: .red)
                    ProfileRow(icon: "envelope.fill", title: "Contact Us", color: .blue)
                    ProfileRow(icon: "doc.text.fill", title: "Terms & Conditions", color: .green)
                    ProfileRow(icon: "rectangle.portrait.and.arrow.right.fill", title: "Log Out", color: .orange)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileRow: View {
    var icon: String
    var title: String
    var color: Color

    private enum ViewTraits {
        static let imageSize: CGFloat = 30
        static let imageInternalPadding: CGFloat = 5
        static let generalPadding: CGFloat = 10
        static let backgroundColor: Color = .secondary.opacity(0.15)
        static let cornerRadius: CGFloat = 10
        static let generalSpacing: CGFloat = 10
        static let cellHeight: CGFloat = 70
    }
    
    var body: some View {
        HStack(spacing: ViewTraits.generalPadding) {
            Image(systemName: icon)
                .resizable()
                .frame(width: ViewTraits.imageSize, height: ViewTraits.imageSize)
                .aspectRatio(contentMode: .fill)
                .padding(ViewTraits.imageInternalPadding)
                .background(color)
                .foregroundColor(.white)
                .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))

            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.headline)
//                Text(expense.paymentMethod.rawValue)
//                    .font(.caption)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 20, height: 20)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.gray)
        }
        .padding(ViewTraits.generalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: ViewTraits.cellHeight)
        .background(ViewTraits.backgroundColor)
        .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))
        .listRowSeparator(.hidden)
    }
}


#Preview {
    ProfileView()
}
