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
    @Environment(\.authVM) private var authVM: AuthenticationModelProtocol

    var body: some View {
        ZStack {
            Color.mintAccent
                .opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("logoPNG")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .aspectRatio(contentMode: .fit)

                MUTextField(text: $username,
                            placeholder: "Nombre de usuario",
                            headerText: "Nombre de usuario",
                            autocapitalization: .words)

                MUTextField(text: $email,
                            placeholder: "Correo electrónico",
                            headerText: "Correo electrónico",
                            autocapitalization: .none)


                MUPasswordField(password: $password,
                                headerText: "Contraseña")

                Button {
                    registerAction()
                } label: {
                    Text("Registrar cuenta")
                        .foregroundColor(.white)
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
