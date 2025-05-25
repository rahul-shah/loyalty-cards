import SwiftUI
import CoreImage.CIFilterBuiltins

struct CardDetailView: View {
    let card: LoyaltyCard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteAlert = false
    
    var backgroundColor: Color {
        Color(card.backgroundColor ?? "blue")
    }
    
    private func deleteCard() {
        viewContext.delete(card)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting card: \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    // Large retailer name
                    Text(card.name ?? "")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // Barcode section
                    VStack(spacing: 16) {
                        if let cardNumber = card.cardNumber {
                            Image(uiImage: generateBarcode(from: cardNumber))
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                            
                            Text(cardNumber)
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Option buttons
                    VStack(spacing: 16) {
                        NavigationLink(destination: CardPicturesView(card: card)) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.primary)
                                Text("Card Pictures")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.primary)
                                Text("Notes")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        // Delete Button
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Text("Delete Card")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Cards")
                    }
                    .foregroundColor(.primary)
                }
            )
            .alert("Delete Card", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteCard()
                }
            } message: {
                Text("Are you sure you want to delete this card? This action cannot be undone.")
            }
        }
    }
    
    private func generateBarcode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.code128BarcodeGenerator()
        let data = string.data(using: String.Encoding.ascii)
        
        filter.message = data!
        filter.quietSpace = 7.0
        
        if let outputImage = filter.outputImage {
            let scaleX = UIScreen.main.bounds.width / outputImage.extent.size.width
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleX * 2))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage()
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let card = LoyaltyCard(context: context)
    card.name = "Sample Card"
    card.cardNumber = "1234567890"
    card.location = "United Kingdom"
    card.logoName = "creditcard.fill"
    card.backgroundColor = Color.blue.description
    card.stamps = 3
    card.totalStamps = 10
    
    return CardDetailView(card: card)
} 
