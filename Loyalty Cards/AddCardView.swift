import SwiftUI

struct RetailerCard: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let logoName: String
    let backgroundColor: Color
    let isGeneric: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RetailerCard, rhs: RetailerCard) -> Bool {
        lhs.id == rhs.id
    }
}

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedRetailer: RetailerCard?
    
    let retailers = [
        // Generic Card Option
        RetailerCard(name: "Add Other Card", category: "Custom", logoName: "plus.circle.fill", backgroundColor: Color(hex: "007AFF"), isGeneric: true),
        
        // Supermarkets
        RetailerCard(name: "Tesco Clubcard", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "00539F"), isGeneric: false),
        RetailerCard(name: "Nectar (Sainsbury's)", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "EC8A00"), isGeneric: false),
        RetailerCard(name: "Waitrose", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "86B847"), isGeneric: false),
        RetailerCard(name: "Marks & Spencer Sparks", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "C4CDD5"), isGeneric: false),
        RetailerCard(name: "Co-op Membership", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "00B1E7"), isGeneric: false),
        RetailerCard(name: "Iceland Bonus Card", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "D10000"), isGeneric: false),
        RetailerCard(name: "Lidl Plus", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "0050AA"), isGeneric: false),
        RetailerCard(name: "Morrisons More", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "004F38"), isGeneric: false),
        RetailerCard(name: "Asda Rewards", category: "Supermarket", logoName: "cart.fill", backgroundColor: Color(hex: "78BE20"), isGeneric: false),
        
        // Health & Beauty
        RetailerCard(name: "Boots Advantage", category: "Health & Beauty", logoName: "cross.fill", backgroundColor: Color(hex: "184290"), isGeneric: false),
        RetailerCard(name: "Superdrug Health & Beautycard", category: "Health & Beauty", logoName: "cross.fill", backgroundColor: Color(hex: "E31B23"), isGeneric: false),
        RetailerCard(name: "The Body Shop", category: "Health & Beauty", logoName: "sparkles", backgroundColor: Color(hex: "004236"), isGeneric: false),
        RetailerCard(name: "Holland & Barrett", category: "Health & Beauty", logoName: "leaf.fill", backgroundColor: Color(hex: "00594C"), isGeneric: false),
        
        // Food & Drink
        RetailerCard(name: "Costa Club", category: "Coffee & Food", logoName: "cup.and.saucer.fill", backgroundColor: Color(hex: "642B2B"), isGeneric: false),
        RetailerCard(name: "Starbucks Rewards", category: "Coffee", logoName: "cup.and.saucer.fill", backgroundColor: Color(hex: "006241"), isGeneric: false),
        RetailerCard(name: "Nando's", category: "Restaurant", logoName: "flame.fill", backgroundColor: Color(hex: "7C2529"), isGeneric: false),
        RetailerCard(name: "Pret Coffee Subscription", category: "Coffee & Food", logoName: "cup.and.saucer.fill", backgroundColor: Color(hex: "B01F24"), isGeneric: false),
        RetailerCard(name: "Greggs Rewards", category: "Food", logoName: "takeoutbag.and.cup.and.straw.fill", backgroundColor: Color(hex: "00558C"), isGeneric: false),
        RetailerCard(name: "Subway Rewards", category: "Food", logoName: "takeoutbag.and.cup.and.straw.fill", backgroundColor: Color(hex: "008C15"), isGeneric: false),
        RetailerCard(name: "Pizza Express Club", category: "Restaurant", logoName: "fork.knife", backgroundColor: Color(hex: "00205B"), isGeneric: false),
        RetailerCard(name: "itsu", category: "Restaurant", logoName: "fork.knife", backgroundColor: Color(hex: "FF0000"), isGeneric: false),
        RetailerCard(name: "Wasabi", category: "Restaurant", logoName: "fork.knife", backgroundColor: Color(hex: "A0C03B"), isGeneric: false),
        RetailerCard(name: "YO! Sushi", category: "Restaurant", logoName: "fork.knife", backgroundColor: Color(hex: "FF0000"), isGeneric: false),
        
        // Fashion & Department Stores
        RetailerCard(name: "H&M Member", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "E50010"), isGeneric: false),
        RetailerCard(name: "John Lewis My John Lewis", category: "Department Store", logoName: "bag.fill", backgroundColor: Color(hex: "85754E"), isGeneric: false),
        RetailerCard(name: "Argos", category: "Retail", logoName: "cart.fill", backgroundColor: Color(hex: "D42114"), isGeneric: false),
        RetailerCard(name: "Primark Rewards", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "0088CC"), isGeneric: false),
        RetailerCard(name: "Uniqlo", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "FF0000"), isGeneric: false),
        RetailerCard(name: "Zara", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "000000"), isGeneric: false),
        RetailerCard(name: "New Look", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "D6168B"), isGeneric: false),
        RetailerCard(name: "River Island", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "000000"), isGeneric: false),
        RetailerCard(name: "TK Maxx Treasure", category: "Fashion", logoName: "tshirt.fill", backgroundColor: Color(hex: "D4002A"), isGeneric: false),
        RetailerCard(name: "House of Fraser Recognition", category: "Department Store", logoName: "bag.fill", backgroundColor: Color(hex: "000000"), isGeneric: false),
        
        // Home & DIY
        RetailerCard(name: "B&Q Club", category: "Home & DIY", logoName: "hammer.fill", backgroundColor: Color(hex: "F7A600"), isGeneric: false),
        RetailerCard(name: "Homebase", category: "Home & DIY", logoName: "hammer.fill", backgroundColor: Color(hex: "00923F"), isGeneric: false),
        RetailerCard(name: "Dunelm", category: "Home", logoName: "house.fill", backgroundColor: Color(hex: "EE3124"), isGeneric: false),
        RetailerCard(name: "IKEA Family", category: "Home", logoName: "house.fill", backgroundColor: Color(hex: "0051BA"), isGeneric: false),
        RetailerCard(name: "Wilko", category: "Home & DIY", logoName: "house.fill", backgroundColor: Color(hex: "CC0033"), isGeneric: false),
        RetailerCard(name: "The Range", category: "Home", logoName: "house.fill", backgroundColor: Color(hex: "0066B3"), isGeneric: false),
        
        // Books & Entertainment
        RetailerCard(name: "Waterstones Plus", category: "Books", logoName: "book.fill", backgroundColor: Color(hex: "000000"), isGeneric: false),
        RetailerCard(name: "WHSmith", category: "Books & Stationery", logoName: "book.fill", backgroundColor: Color(hex: "D42114"), isGeneric: false),
        RetailerCard(name: "GAME Reward", category: "Gaming", logoName: "gamecontroller.fill", backgroundColor: Color(hex: "6C2C8F"), isGeneric: false),
        RetailerCard(name: "HMV Pure", category: "Entertainment", logoName: "music.note", backgroundColor: Color(hex: "FF1C26"), isGeneric: false),
        
        // Sports & Outdoors
        RetailerCard(name: "Sports Direct", category: "Sports", logoName: "figure.run", backgroundColor: Color(hex: "0C1C8C"), isGeneric: false),
        RetailerCard(name: "Decathlon", category: "Sports", logoName: "figure.run", backgroundColor: Color(hex: "0082C3"), isGeneric: false),
        RetailerCard(name: "GO Outdoors", category: "Outdoors", logoName: "mountain.2.fill", backgroundColor: Color(hex: "004B8D"), isGeneric: false),
        RetailerCard(name: "JD Sports", category: "Sports", logoName: "figure.run", backgroundColor: Color(hex: "000000"), isGeneric: false),
        
        // Electronics & Mobile
        RetailerCard(name: "Currys Perks", category: "Electronics", logoName: "tv.fill", backgroundColor: Color(hex: "000000"), isGeneric: false),
        RetailerCard(name: "O2 Priority", category: "Mobile", logoName: "phone.fill", backgroundColor: Color(hex: "0019A5"), isGeneric: false),
        RetailerCard(name: "Three Rewards", category: "Mobile", logoName: "phone.fill", backgroundColor: Color(hex: "4B0082"), isGeneric: false),
        RetailerCard(name: "Vodafone VeryMe", category: "Mobile", logoName: "phone.fill", backgroundColor: Color(hex: "E60000"), isGeneric: false),
        
        // Others
        RetailerCard(name: "Pets at Home VIP", category: "Pets", logoName: "pawprint.fill", backgroundColor: Color(hex: "00A0DF"), isGeneric: false),
        RetailerCard(name: "Paperchase", category: "Stationery", logoName: "pencil", backgroundColor: Color(hex: "E31C79"), isGeneric: false),
        RetailerCard(name: "Ryman", category: "Stationery", logoName: "pencil", backgroundColor: Color(hex: "004B8D"), isGeneric: false),
        RetailerCard(name: "Robert Dyas", category: "Home & DIY", logoName: "hammer.fill", backgroundColor: Color(hex: "004F9F"), isGeneric: false)
    ]
    
    var filteredRetailers: [RetailerCard] {
        if searchText.isEmpty {
            return retailers.sorted { $0.name < $1.name }
        } else {
            return retailers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.name < $1.name }
        }
    }
    
    var groupedRetailers: [String: [RetailerCard]] {
        Dictionary(grouping: filteredRetailers) { String($0.name.prefix(1)) }
    }
    
    var sortedGroups: [(key: String, retailers: [RetailerCard])] {
        groupedRetailers.map { (key: $0.key, retailers: $0.value) }
            .sorted { $0.key < $1.key }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedGroups, id: \.key) { group in
                    Section(header: Text(group.key)) {
                        ForEach(group.retailers) { retailer in
                            RetailerRow(retailer: retailer)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRetailer = retailer
                                }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search retailers")
            .navigationTitle("Add Loyalty Card")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .sheet(item: $selectedRetailer) { retailer in
                CardNumberEntryView(
                    retailer: retailer,
                    onComplete: {
                        dismiss()
                    }
                )
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct RetailerRow: View {
    let retailer: RetailerCard
    
    var body: some View {
        HStack {
            Circle()
                .fill(retailer.backgroundColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: retailer.logoName)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text(retailer.name)
                    .font(.headline)
                Text(retailer.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
} 