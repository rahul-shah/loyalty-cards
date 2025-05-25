import SwiftUI
import PhotosUI
import CoreData

struct CardPicturesView: View {
    let card: LoyaltyCard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingFrontImagePicker = false
    @State private var showingBackImagePicker = false
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var showingCamera = false
    @State private var isCapturingFront = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Front section
                Text("Front")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Button(action: {
                    isCapturingFront = true
                    showingCamera = true
                }) {
                    if let frontImage = frontImage {
                        Image(uiImage: frontImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(12)
                                .frame(height: 200)
                            
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.black)
                                
                                Text("Tap to add photo")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Back section
                Text("Back")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                Button(action: {
                    isCapturingFront = false
                    showingCamera = true
                }) {
                    if let backImage = backImage {
                        Image(uiImage: backImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(12)
                                .frame(height: 200)
                            
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.black)
                                
                                Text("Tap to add photo")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Card Pictures")
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: isCapturingFront ? $frontImage : $backImage, sourceType: .camera)
                .ignoresSafeArea()
                .onDisappear {
                    if isCapturingFront {
                        if let imageData = frontImage?.jpegData(compressionQuality: 0.8) {
                            card.frontImage = imageData
                        }
                    } else {
                        if let imageData = backImage?.jpegData(compressionQuality: 0.8) {
                            card.backImage = imageData
                        }
                    }
                    saveContext()
                }
        }
        .onAppear {
            // Load existing images if available
            if let frontImageData = card.frontImage {
                frontImage = UIImage(data: frontImageData)
            }
            if let backImageData = card.backImage {
                backImage = UIImage(data: backImageData)
            }
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let card = LoyaltyCard(context: context)
    card.name = "Sample Card"
    card.cardNumber = "1234567890"
    
    return CardPicturesView(card: card)
        .environment(\.managedObjectContext, context)
} 