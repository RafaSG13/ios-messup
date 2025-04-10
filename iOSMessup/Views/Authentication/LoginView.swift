//
//  LoginView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//
import SwiftUI
import SwiftUI

struct LoginView: View {

    @Environment(\.authVM) private var authVM: AuthenticationModelProtocol
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @StateObject private var loginVM = LoginViewModel()


    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                MUTextField(text: $loginVM.email,
                            placeholder: "Email",
                            headerText: "Email",
                            autocapitalization: .none)

                MUPasswordField(password: $loginVM.password,
                                headerText: "Password")

                Button {
                    Task { await loginVM.loginAction(with: authVM) }
                } label: {
                    Text("Iniciar Sesión")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.mint)
                        .cornerRadius(10)
                }
                .alert("Error", isPresented: $loginVM.shouldPresentAlert, presenting: loginVM.error) { _ in
                    Button("Close", role: .cancel) { loginVM.shouldPresentAlert = false }
                } message: { error in
                    Text((error as? LocalizedError)?.errorDescription ?? "Something went wrong.")
                }
            }
            .padding()
            .padding(.horizontal)
        }
        
    }
    
    func loginAction() {
        Task {
            try await authVM.login(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
}

// MARK: - ViewModel to wrap properties and logic

class LoginViewModel: ObservableObject {
    @Published var email: String = "rafasrrg13@gmail.com"
    @Published var password: String = "Contrasena_123"
    @Published var shouldPresentAlert: Bool = false
    @Published var error: Error?

    func loginAction(with authVM: AuthenticationModelProtocol) async {
        do {
            try await authVM.login(email: email, password: password)
        } catch let error {
            self.error = error
            shouldPresentAlert = true
        }
    }
}
