//
//  RegistrationView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email: String = "rafasrrg13@gmail.com"
    @State private var username: String = "Rafael Serrano Gamarra"
    @State private var password: String = "Contrasena_123"
    @Environment(\.authenticationService) private var authenticationService

    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            MUTextField(text: $username,
                        placeholder: "Username",
                        headerText: "Username",
                        autocapitalization: .words)
            
            MUTextField(text: $email,
                        placeholder: "Email",
                        headerText: "Email",
                        autocapitalization: .none)
            
            
            MUPasswordField(password: $password,
                            headerText: "Password")
            Button {
                registerAction()
            } label: {
                Text("Sign Up")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.mint)
                    .cornerRadius(10)
            }
        }
        .padding()
        .padding(.horizontal)
    }
    
    func registerAction() {
        Task {
            try await authenticationService.register(email: email, password: password, name: username)
        }
    }
}

#Preview {
    RegistrationView()
}
