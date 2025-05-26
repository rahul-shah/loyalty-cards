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
        if let colorString = card.backgroundColor {
            return Color(colorString)
        }
        return Color(hex: "333333") // Default dark gray
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
