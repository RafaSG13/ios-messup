//
//  ProfileCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 1/2/25.
//

import SwiftUI

enum ProfileRowModel: Int, CaseIterable {
    case settings
    case changePassword
    case contactUs
    case termsAndConditions
    case logOut
    
    var icon: String {
        switch self {
        case .settings: return "gearshape.circle.fill"
        case .changePassword: return "lock.circle.fill"
        case .contactUs: return "envelope.circle.fill"
        case .termsAndConditions: return "doc.circle.fill"
        case .logOut: return "multiply.circle.fill"
        }
    }
    
    var title: String {
        switch self {
        case .settings: return "Settings"
        case .changePassword: return "Change Password"
        case .contactUs: return "Contact Us"
        case .termsAndConditions: return "Terms & Conditions"
        case .logOut: return "Log Out"
        }
    }
    
    var color: Color {
        switch self {
        case .settings: return .gray
        case .changePassword: return .orange
        case .contactUs: return .blue
        case .termsAndConditions: return .green
        case .logOut: return .red
        }
    }
}

struct ProfileRow: View {
    let model: ProfileRowModel
    
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
            Image(systemName: model.icon)
                .resizable()
                .frame(width: ViewTraits.imageSize, height: ViewTraits.imageSize)
                .scaledToFit()
                .padding(.vertical, ViewTraits.imageInternalPadding)
                .foregroundColor(model.color)
            
            Text(model.title)
                .font(.headline.bold())
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ProfileRow(model: .changePassword)
}
