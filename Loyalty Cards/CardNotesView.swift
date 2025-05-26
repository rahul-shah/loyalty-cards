import SwiftUI

struct CardNotesView: View {
    let card: LoyaltyCard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var notes: String
    
    init(card: LoyaltyCard) {
        self.card = card
        // Initialize notes with existing value or empty string
        _notes = State(initialValue: card.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Notes text editor
                TextEditor(text: $notes)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveNotes()
                }
            )
            .padding(.vertical)
        }
    }
    
    private func saveNotes() {
        card.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving notes: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let card = LoyaltyCard(context: context)
    card.name = "Sample Card"
    card.notes = "Sample notes for this card"
    
    return CardNotesView(card: card)
        .environment(\.managedObjectContext, context)
} 