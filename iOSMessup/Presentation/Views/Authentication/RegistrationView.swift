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


struct MUTextField: View {
    @Binding var text: String
    var placeholder: String
    var headerText: String
    var autocapitalization: UITextAutocapitalizationType = .none

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(headerText)
                .font(.callout)
                .foregroundColor(.accent)
                .bold()
            TextField(placeholder, text: $text)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
                .autocapitalization(autocapitalization)
        }
    }
}


struct MUPasswordField: View {
    @Binding var password: String
    var headerText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(headerText)
                .font(.callout)
                .foregroundColor(.accent)
                .bold()
            SecureField("Contraseña", text: $password)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
        }
    }
}

#Preview {
    RegistrationView()
}
