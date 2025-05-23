//
//  RegisterView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var confirmPassword = ""
    
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
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primaryText)
                    
                    Text("Join our sports community")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.top, 50)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Full Name", text: $fullname)
                        .textFieldStyle(SportHubTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(SportHubTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(SportHubTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(SportHubTextFieldStyle())
                    
                    Button(action: register) {
                        Text("Register")
                            .authButtonStyle()
                    }
                    .disabled(!formIsValid)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(Theme.accentOrange)
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password == confirmPassword &&
        !fullname.isEmpty &&
        password.count >= 6
    }
    
    private func register() {
        Task {
            await authViewModel.register(
                withEmail: email,
                password: password,
                fullname: fullname
            )
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
