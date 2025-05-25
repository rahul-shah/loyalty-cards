import SwiftUI

struct RetailerCard: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let logoName: String
    let backgroundColor: Color
    
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
        RetailerCard(name: "Argos", category: "Retail", logoName: "cart.fill", backgroundColor: .blue),
        RetailerCard(name: "Boots", category: "Health & Beauty", logoName: "cross.fill", backgroundColor: .blue),
        RetailerCard(name: "Costa Coffee", category: "Coffee & Food", logoName: "cup.and.saucer.fill", backgroundColor: .red),
        RetailerCard(name: "Greggs", category: "Food", logoName: "fork.knife", backgroundColor: .blue),
        RetailerCard(name: "H&M", category: "Fashion", logoName: "tshirt.fill", backgroundColor: .red),
        RetailerCard(name: "John Lewis", category: "Retail", logoName: "bag.fill", backgroundColor: .green),
        RetailerCard(name: "Marks & Spencer", category: "Retail", logoName: "bag.fill", backgroundColor: .green),
        RetailerCard(name: "Nando's", category: "Restaurant", logoName: "fork.knife", backgroundColor: .red),
        RetailerCard(name: "Nectar (Sainsbury's)", category: "Supermarket", logoName: "cart.fill", backgroundColor: .orange),
        RetailerCard(name: "Pret A Manger", category: "Coffee & Food", logoName: "cup.and.saucer.fill", backgroundColor: .red),
        RetailerCard(name: "Starbucks", category: "Coffee", logoName: "cup.and.saucer.fill", backgroundColor: .green),
        RetailerCard(name: "Superdrug", category: "Health & Beauty", logoName: "cross.fill", backgroundColor: .pink),
        RetailerCard(name: "Tesco Clubcard", category: "Supermarket", logoName: "cart.fill", backgroundColor: .blue),
        RetailerCard(name: "The Body Shop", category: "Health & Beauty", logoName: "sparkles", backgroundColor: .green),
        RetailerCard(name: "Waitrose", category: "Supermarket", logoName: "cart.fill", backgroundColor: .green)
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