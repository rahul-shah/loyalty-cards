import SwiftUI
import CoreData

struct CardsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LoyaltyCard.name, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<LoyaltyCard>
    
    @State private var showingAddCard = false
    @State private var selectedCard: LoyaltyCard?
    @State private var cardToDelete: LoyaltyCard?
    @State private var showingDeleteAlert = false
    
    private func deleteCard(_ card: LoyaltyCard) {
        withAnimation {
            viewContext.delete(card)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting card: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(cards) { card in
                            Button(action: {
                                selectedCard = card
                            }) {
                                StoredCardView(card: card)
                            }
                            .buttonStyle(.plain)
                            .onLongPressGesture {
                                cardToDelete = card
                                showingDeleteAlert = true
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.bottom, 80) // Add padding for bottom bar
                }
                
                // Bottom Navigation Bar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showingAddCard = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .systemBackground))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(uiColor: .separator)),
                        alignment: .top
                    )
                }
            }
            .navigationTitle("My Cards")
            .navigationBarItems(
                leading: Button(action: {}) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                },
                trailing: Button(action: {}) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 24))
                }
            )
            .sheet(isPresented: $showingAddCard) {
                AddCardView()
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
            .alert("Delete Card", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let card = cardToDelete {
                        deleteCard(card)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this card? This action cannot be undone.")
            }
        }
    }
}

struct StoredCardView: View {
    let card: LoyaltyCard
    @State private var isPressed = false
    
    var brandColor: Color {
        switch card.name?.lowercased() {
        case "tesco clubcard":
            return Color(hex: "00539F") // Tesco blue
        case "boots":
            return Color(hex: "184290") // Boots blue
        case "costa coffee":
            return Color(hex: "642B2B") // Costa maroon
        case "starbucks":
            return Color(hex: "006241") // Starbucks green
        case "nectar (sainsbury's)":
            return Color(hex: "EC8A00") // Sainsbury's orange
        case "waitrose":
            return Color(hex: "86B847") // Waitrose green
        case "marks & spencer":
            return Color(hex: "C4CDD5") // M&S silver/gray
        case "superdrug":
            return Color(hex: "E31B23") // Superdrug red
        case "the body shop":
            return Color(hex: "004236") // Body Shop green
        case "nando's":
            return Color(hex: "7C2529") // Nando's red
        case "pret a manger":
            return Color(hex: "B01F24") // Pret red
        case "greggs":
            return Color(hex: "00558C") // Greggs blue
        case "h&m":
            return Color(hex: "E50010") // H&M red
        case "john lewis":
            return Color(hex: "85754E") // John Lewis gold
        case "argos":
            return Color(hex: "D42114") // Argos red
        default:
            return Color(hex: "333333") // Default dark gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Logo circle
                Circle()
                    .fill(.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: card.logoName ?? "creditcard.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(brandColor)
                    )
                
                Text(card.name ?? "")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Category icon
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: getCategoryIcon(for: card.name ?? ""))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(brandColor)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(height: 100)
    }
    
    private func getCategoryIcon(for name: String) -> String {
        switch name.lowercased() {
        case "starbucks", "black rifle coffee":
            return "cup.and.saucer.fill"
        case "kfc":
            return "drumstick.fill"
        case "domino's pizza", "dominos":
            return "pizza.fill"
        default:
            return "creditcard.fill"
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

struct CardsListView_Previews: PreviewProvider {
    static var previews: some View {
        CardsListView()
    }
} 
