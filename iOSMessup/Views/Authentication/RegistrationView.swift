//
//  RegistrationView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email: String = "rafasrrg1@gmail.com"
    @State private var username: String = "Rafael"
    @State private var password: String = "Contrasena_123"
    @State private var confirmPassword: String = "Contrasena_123"
    @Environment(\.authVM) var authVM: AuthenticationModelProtocol

    var body: some View {
        NavigationView {
            VStack {
                Text("Crear una cuenta")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 40)
                
                TextField("Nombre de usuario", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.horizontal)
                    .autocapitalization(.none)

                TextField("Correo electrónico", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.horizontal)
                    .autocapitalization(.none)

                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.horizontal)
                
                SecureField("Confirmar contraseña", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.horizontal)

                Button {
                    Task {
                        try await authVM.register(email: email, password: password, name: username)
                    }
                } label: {
                    Text("Registrar cuenta")
                        .foregroundColor(.white)
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
        }
    }
}
