import SwiftUI

struct CardNumberEntryView: View {
    let retailer: RetailerCard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var cardNumber = ""
    @State private var customName = ""
    @State private var selectedColor = Color.blue
    @State private var showError = false
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Retailer header
                if !retailer.isGeneric {
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
                }
                
                // Custom name field for generic cards
                if retailer.isGeneric {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Name")
                            .foregroundColor(.gray)
                        TextField("Enter the name of your loyalty card", text: $customName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    .padding(.horizontal)
                    
                    // Color picker for generic cards
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Color")
                            .foregroundColor(.gray)
                        ColorPicker("Select card color", selection: $selectedColor)
                            .labelsHidden()
                        
                        // Color preview
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedColor)
                            .frame(height: 60)
                            .overlay(
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            )
                    }
                    .padding(.horizontal)
                }
                
                // Card number entry
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Number")
                        .foregroundColor(.gray)
                    TextField("Enter your loyalty card number", text: $cardNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
                
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
                            isFormValid ? Color.blue : Color.gray
                        )
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .padding()
            }
            .navigationTitle(retailer.isGeneric ? "Add Custom Card" : "Add Card Details")
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
    
    private var isFormValid: Bool {
        if retailer.isGeneric {
            return !cardNumber.isEmpty && !customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return !cardNumber.isEmpty
    }
    
    private func addCard() {
        let card = LoyaltyCard(context: viewContext)
        card.id = UUID()
        card.name = retailer.isGeneric ? customName : retailer.name
        card.category = retailer.category
        card.logoName = retailer.isGeneric ? "creditcard.fill" : retailer.logoName
        card.backgroundColor = retailer.isGeneric ? selectedColor.description : retailer.backgroundColor.description
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
            backgroundColor: .blue,
            isGeneric: false
        ),
        onComplete: {}
    )
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
} 