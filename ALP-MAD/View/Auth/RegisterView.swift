import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)

                    Text("Create your account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)

                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                            TextField("Full Name", text: $name)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)

                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)

                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Password", text: $password)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.lightGray)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        // Handle registration logic here
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

                    NavigationLink(destination: LoginView()) {
                        Text("Already have an account? Login")
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
    RegisterView()
}
