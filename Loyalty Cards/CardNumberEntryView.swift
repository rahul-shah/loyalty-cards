import SwiftUI

struct CardNumberEntryView: View {
    let retailer: RetailerCard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var cardNumber = ""
    @State private var showError = false
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Retailer header
                HStack {
                    Circle()
                        .fill(retailer.backgroundColor)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: retailer.logoName)
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        )
                    
                    VStack(alignment: .leading) {
                        Text(retailer.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(retailer.category)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Card number entry
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Number")
                        .foregroundColor(.gray)
                    TextField("Enter your loyalty card number", text: $cardNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Add button
                Button(action: {
                    addCard()
                }) {
                    Text("Add Card")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            cardNumber.isEmpty ? Color.gray : Color.blue
                        )
                        .cornerRadius(10)
                }
                .disabled(cardNumber.isEmpty)
                .padding()
            }
            .navigationTitle("Add Card Details")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Failed to save the card. Please try again.")
            }
        }
    }
    
    private func addCard() {
        let card = LoyaltyCard(context: viewContext)
        card.id = UUID()
        card.name = retailer.name
        card.category = retailer.category
        card.logoName = retailer.logoName
        card.backgroundColor = retailer.backgroundColor.description
        card.cardNumber = cardNumber
        card.location = "United Kingdom"
        card.stamps = 0
        card.totalStamps = 10
        
        do {
            try viewContext.save()
            dismiss()
            onComplete()
        } catch {
            print("Error saving card: \(error)")
            showError = true
        }
    }
}

#Preview {
    CardNumberEntryView(
        retailer: RetailerCard(
            name: "Sample Store",
            category: "Retail",
            logoName: "cart.fill",
            backgroundColor: .blue
        ),
        onComplete: {}
    )
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
} 