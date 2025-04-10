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
    @Environment(\.authVM) private var authVM: AuthenticationModelProtocol
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
                    Task {
                        try await authVM.register(email: email, password: password, name: username)
                    }
                } label: {
                    Text("Sign Up")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }


                Spacer()
                
                NavigationLink(destination: LoginView()) {
                    Text("¿Ya tienes una cuenta? Inicia sesión")
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                }
            }
            .padding()
            .padding(.horizontal)
    }

    func registerAction() {
        Task {
            try await authVM.register(email: email, password: password, name: username)
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
