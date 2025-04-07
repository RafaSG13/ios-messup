//
//  LoginView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @Environment(\.authVM) var authVM: AuthenticationModelProtocol

    var body: some View {
        NavigationView {
            VStack {
                Text("Iniciar sesión")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 40)


                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.horizontal)
                    .autocapitalization(.none)

                TextField("Nombre de usuario", text: $username)
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

                Button {
                    Task {
                        try await authVM.login(email: email, password: password)
                    }
                } label: {
                    Text("Iniciar sesión")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                NavigationLink(destination: RegistrationView()) {
                    Text("¿No tienes una cuenta? Regístrate")
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                }
                Spacer()
            }
            .padding()
        }
    }
}
