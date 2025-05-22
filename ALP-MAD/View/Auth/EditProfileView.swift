//
//  EditProfileView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct EditProfileView: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var bio: String

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .black : .orange
    }

    var foregroundColor: Color {
        colorScheme == .dark ? .orange : .black
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                        .foregroundColor(foregroundColor)
                }

                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .foregroundColor(foregroundColor)
                }

                Section(header: Text("Bio")) {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .foregroundColor(foregroundColor)
                }
            }
            .background(backgroundColor)
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                    .foregroundColor(foregroundColor)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

// ✅ FIX PREVIEW
#Preview {
    EditProfileView(
        username: .constant("SampleUser"),
        email: .constant("sample@email.com"),
        bio: .constant("This is a sample bio.")
    )
}
