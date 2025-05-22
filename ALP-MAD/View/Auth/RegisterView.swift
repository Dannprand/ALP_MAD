import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.orange)

                Text("Create your account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)

                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        TextField("Full Name", text: $name)
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
                    }
                    .padding()
                    .background(Color.lightGray)
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
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
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .padding()
        .navigationBarTitle("Register", displayMode: .inline)
    }
}

#Preview {
    RegisterView()
}
