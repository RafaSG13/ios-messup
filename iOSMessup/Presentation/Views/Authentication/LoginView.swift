//
//  LoginView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//
import SwiftUI
import SwiftUI

struct LoginView: View {

    @Environment(\.authenticationService) private var authenticationService
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @State var email: String = "rafasrrg13@gmail.com"
    @State var password: String = "Contrasena_123"
    @State var shouldPresentAlert: Bool = false
    @State var error: Error?


    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                MUTextField(text: $email,
                            placeholder: "Email",
                            headerText: "Email",
                            autocapitalization: .none)

                MUPasswordField(password: $password,
                                headerText: "Password")

                Button {
                    Task {
                        do {
                            try await authenticationService.login(email: email, password: password)
                        } catch let error {
                            self.error = error
                            self.shouldPresentAlert = true
                        }
                    }
                } label: {
                    Text("Iniciar Sesión")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.mint)
                        .cornerRadius(10)
                }
                .alert("Error", isPresented: $shouldPresentAlert, presenting: error) { _ in
                    Button("Close", role: .cancel) { shouldPresentAlert = false }
                } message: { error in
                    Text((error as? LocalizedError)?.errorDescription ?? "Something went wrong.")
                }
            }
            .padding()
            .padding(.horizontal)
        }
    }
}

#Preview {
    LoginView()
}
