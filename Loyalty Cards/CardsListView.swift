import SwiftUI
import CoreData
import AuthenticationServices

struct CardsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LoyaltyCard.name, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<LoyaltyCard>
    
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingAddCard = false
    @State private var selectedCard: LoyaltyCard?
    @State private var cardToDelete: LoyaltyCard?
    @State private var showingDeleteAlert = false
    @State private var showingProfileMenu = false
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var scrollOffset: CGFloat = 0
    @State private var previousScrollOffset: CGFloat = 0
    
    private var filteredCards: [LoyaltyCard] {
        if searchText.isEmpty {
            return Array(cards)
        } else {
            return cards.filter { card in
                guard let name = card.name else { return false }
                return name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
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
    
    private func signOut() {
        // Revoke Apple ID credential
        if let userIdentifier = UserDefaults.standard.string(forKey: "appleUserIdentifier") {
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                if credentialState == .authorized {
                    // Clear user data
                    UserDefaults.standard.removeObject(forKey: "appleUserIdentifier")
                    UserDefaults.standard.removeObject(forKey: "userName")
                    UserDefaults.standard.removeObject(forKey: "userEmail")
                }
            }
        }
        
        // Sign out user
        authManager.isAuthenticated = false
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if filteredCards.isEmpty {
                    if searchText.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)
                            Text("No Cards Added")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Tap the + button below to add your first loyalty card")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)
                            Text("No Results")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("No cards match your search")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).origin.y)
                        }
                        .frame(height: 0)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(filteredCards) { card in
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
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSearch = value > previousScrollOffset && abs(value - previousScrollOffset) > 10
                            previousScrollOffset = value
                        }
                    }
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
                leading: Button(action: {
                    showingProfileMenu = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                },
                trailing: Button(action: {
                    withAnimation {
                        showSearch.toggle()
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                }
            )
            .searchable(text: $searchText, isPresented: $showSearch, prompt: "Search cards")
            .confirmationDialog("Profile Options", isPresented: $showingProfileMenu) {
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
                Button("Cancel", role: .cancel) {}
            }
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
        // Supermarkets
        case "tesco clubcard":
            return Color(hex: "00539F") // Tesco blue
        case "nectar (sainsbury's)":
            return Color(hex: "EC8A00") // Sainsbury's orange
        case "waitrose":
            return Color(hex: "86B847") // Waitrose green
        case "marks & spencer sparks":
            return Color(hex: "C4CDD5") // M&S silver/gray
        case "co-op membership":
            return Color(hex: "00B1E7") // Co-op blue
        case "iceland bonus card":
            return Color(hex: "D10000") // Iceland red
        case "lidl plus":
            return Color(hex: "0050AA") // Lidl blue
        case "morrisons more":
            return Color(hex: "004F38") // Morrisons green
        case "asda rewards":
            return Color(hex: "78BE20") // Asda green
            
        // Health & Beauty
        case "boots advantage":
            return Color(hex: "184290") // Boots blue
        case "superdrug health & beautycard":
            return Color(hex: "E31B23") // Superdrug red
        case "the body shop":
            return Color(hex: "004236") // Body Shop green
        case "holland & barrett":
            return Color(hex: "00594C") // Holland & Barrett green
            
        // Food & Drink
        case "costa club":
            return Color(hex: "642B2B") // Costa maroon
        case "starbucks rewards":
            return Color(hex: "006241") // Starbucks green
        case "nando's":
            return Color(hex: "7C2529") // Nando's red
        case "pret coffee subscription":
            return Color(hex: "B01F24") // Pret red
        case "greggs rewards":
            return Color(hex: "00558C") // Greggs blue
        case "subway rewards":
            return Color(hex: "008C15") // Subway green
        case "pizza express club":
            return Color(hex: "00205B") // Pizza Express blue
        case "itsu":
            return Color(hex: "FF0000") // itsu red
        case "wasabi":
            return Color(hex: "A0C03B") // Wasabi green
        case "yo! sushi":
            return Color(hex: "FF0000") // YO! red
            
        // Fashion & Department Stores
        case "h&m member":
            return Color(hex: "E50010") // H&M red
        case "john lewis my john lewis":
            return Color(hex: "85754E") // John Lewis gold
        case "argos":
            return Color(hex: "D42114") // Argos red
        case "primark rewards":
            return Color(hex: "0088CC") // Primark blue
        case "uniqlo":
            return Color(hex: "FF0000") // Uniqlo red
        case "zara":
            return Color(hex: "000000") // Zara black
        case "new look":
            return Color(hex: "D6168B") // New Look pink
        case "river island":
            return Color(hex: "000000") // River Island black
        case "tk maxx treasure":
            return Color(hex: "D4002A") // TK Maxx red
        case "house of fraser recognition":
            return Color(hex: "000000") // House of Fraser black
            
        // Home & DIY
        case "b&q club":
            return Color(hex: "F7A600") // B&Q orange
        case "homebase":
            return Color(hex: "00923F") // Homebase green
        case "dunelm":
            return Color(hex: "EE3124") // Dunelm red
        case "ikea family":
            return Color(hex: "0051BA") // IKEA blue
        case "wilko":
            return Color(hex: "CC0033") // Wilko red
        case "the range":
            return Color(hex: "0066B3") // The Range blue
            
        // Books & Entertainment
        case "waterstones plus":
            return Color(hex: "000000") // Waterstones black
        case "whsmith":
            return Color(hex: "D42114") // WHSmith red
        case "game reward":
            return Color(hex: "6C2C8F") // GAME purple
        case "hmv pure":
            return Color(hex: "FF1C26") // HMV red
            
        // Sports & Outdoors
        case "sports direct":
            return Color(hex: "0C1C8C") // Sports Direct blue
        case "decathlon":
            return Color(hex: "0082C3") // Decathlon blue
        case "go outdoors":
            return Color(hex: "004B8D") // GO Outdoors blue
        case "jd sports":
            return Color(hex: "000000") // JD black
            
        // Electronics & Mobile
        case "currys perks":
            return Color(hex: "000000") // Currys black
        case "o2 priority":
            return Color(hex: "0019A5") // O2 blue
        case "three rewards":
            return Color(hex: "4B0082") // Three purple
        case "vodafone veryme":
            return Color(hex: "E60000") // Vodafone red
            
        // Others
        case "pets at home vip":
            return Color(hex: "00A0DF") // Pets at Home blue
        case "paperchase":
            return Color(hex: "E31C79") // Paperchase pink
        case "ryman":
            return Color(hex: "004B8D") // Ryman blue
        case "robert dyas":
            return Color(hex: "004F9F") // Robert Dyas blue
            
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

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 
