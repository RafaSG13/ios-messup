//
//  LandingView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 8/4/25.
//

import SwiftUI

struct LandingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var navigateToLogin = false
    @State private var navigateToRegister = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mintAccent.opacity(0.2)
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    Image("logoPNG")
                        .resizable()
                        .frame(width: 270, height: 270)
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical)

                    Text("Welcome to Messup!!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.mint)
                        .padding(.top)


                    Text("Your all-in-one space to track expenses, manage your finances, and connect with your community. Record, save, and share — all in one place.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .padding(.vertical)



                    Button {
                        navigateToLogin.toggle()
                    } label: {
                        Text("Login")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mint)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)

                    Button {
                        navigateToRegister.toggle()
                    } label: {
                        Text("Sign up")
                            .foregroundColor(Color.mint)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.mint, lineWidth: 2)
                            )
                    }
                    .padding(.vertical)
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView()
                }
                .navigationDestination(isPresented: $navigateToRegister) {
                    RegistrationView()
                }
            }
        }
    }
}

#Preview {
    LandingView()
}
