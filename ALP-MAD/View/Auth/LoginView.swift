import SwiftUI

extension Color {
    static let primaryOrange = Color("PrimaryOrange")
    static let lightGray = Color(.systemGray6)
    static let darkGray = Color(.systemGray)
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSecure = true

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "sportscourt.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)

                    Text("Welcome to SportHUB")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)

                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)

                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)

                            if isSecure {
                                SecureField("Password", text: $password)
                            } else {
                                TextField("Password", text: $password)
                            }

                            Button(action: {
                                isSecure.toggle()
                            }) {
                                Image(systemName: isSecure ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        // Handle login logic here
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.orange : Color.darkGray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .animation(.easeInOut(duration: 0.2), value: isFormValid)

                    NavigationLink(destination: RegisterView()) {
                        Text("Don't have an account? Register")
                            .foregroundColor(.orange)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LoginView()
}
