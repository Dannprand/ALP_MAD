import SwiftUI
import PhotosUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var hostName = ""
    @State private var eventDescription = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("Create New Event")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)

                    // Image Picker Area
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Image")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        Button(action: { isShowingImagePicker = true }) {
                            ZStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange, lineWidth: 2)
                                        )
                                } else {
                                    VStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(.orange)
                                        Text("Tap to upload image")
                                            .foregroundColor(.white.opacity(0.8))
                                            .font(.subheadline)
                                    }
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .sheet(isPresented: $isShowingImagePicker) {
                            ImagePicker(selectedImage: $selectedImage)
                        }
                    }

                    // Event Title Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event Title")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("", text: $eventTitle)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }

                    // Date Picker Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event Date")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("", selection: $eventDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .colorScheme(.dark)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }

                    // Host Name Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Host Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("", text: $hostName)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    
                    // Description Text Editor
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event Description")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack(alignment: .topLeading) {
                            if eventDescription.isEmpty {
                                Text("Write something...")
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                            
                            TextField("", text: $eventDescription, axis: .vertical)
                                .lineLimit(5...10)
                                .padding()
                                .frame(minHeight: 120, alignment: .topLeading)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }

                    
                    // Submit Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Create Event")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.orange)
                        .font(.system(size: 18, weight: .bold))
                }
            )
        }
    }
}


// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddEventView()
}

