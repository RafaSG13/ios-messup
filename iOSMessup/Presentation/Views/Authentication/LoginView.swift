//
//  LoginView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//
import SwiftUI
import SwiftUI

struct LoginView: View {

    private enum TaskId { case login }

    @Environment(\.authService) private var authenticationService
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @State var email: String = "rafasrrg13@gmail.com"
    @State var password: String = "Contrasena_123"
    @State var shouldPresentAlert: Bool = false
    @State var error: Error?

    private let tasks = TaskStore()

    var body: some View {
        ZStack {
            VStack(spacing: MUSpacer.size06) {
                MUTextField(text: $email,
                            placeholder: "Email",
                            headerText: "Email",
                            autocapitalization: .none,
                            textContentType: .emailAddress)

                MUPasswordField(password: $password,
                                headerText: "Password")

                Button {
                    loginAction()
                } label: {
                    Text("Iniciar Sesión")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.mint)
                        .cornerRadius(10)
                }
                .onDisappear { tasks.cancelAll() }
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

    private func loginAction() {
        tasks.main(TaskId.login) {
            do {
                try await authenticationService.login(email: email, password: password)
            } catch let error {
                self.error = error
                self.shouldPresentAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
}
