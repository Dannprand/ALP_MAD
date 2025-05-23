//
//  LoginView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "sportscourt.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Theme.accentOrange)
                    
                    Text("SportHub")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primaryText)
                    
                    Text("Connect with sports events near you")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.top, 50)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(SportHubTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(SportHubTextFieldStyle())
                    
                    Button(action: {
                        Task { await authViewModel.login(withEmail: email, password: password) }
                    }) {
                        Text("Login")
                            .authButtonStyle()
                    }
                    
                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Don't have an account? Register")
                            .font(.footnote)
                            .foregroundColor(Theme.accentOrangeLight)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .background(Theme.background.ignoresSafeArea())
            .alert("Error", isPresented: $authViewModel.showError, presenting: authViewModel.error) { error in
                Button("OK", role: .cancel) { }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

struct SportHubTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Theme.cardBackground)
            .cornerRadius(10)
            .foregroundColor(Theme.primaryText)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
            )
    }
}

struct AuthButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accentOrange)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(10)
            .shadow(color: Theme.accentOrange.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func authButtonStyle() -> some View {
        modifier(AuthButtonStyle())
    }
}
