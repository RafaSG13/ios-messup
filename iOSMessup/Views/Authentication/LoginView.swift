//
//  LoginView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//
import SwiftUI

struct LoginView: View {
    @State private var email: String = "rafasrrg1@gmail.com"
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
                
                MUTextField(text: $email,
                            placeholder: "Correo electrónico",
                            headerText: "Correo electrónico",
                            autocapitalization: .none)
                
                MUPasswordField(password: $password,
                                headerText: "Contraseña")
                
                Button {
                    loginAction()
                } label: {
                    Text("Iniciar Sesión")
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.mint)
                        .cornerRadius(10)
                }
                
                
                Spacer()
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
