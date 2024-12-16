import SwiftUI

struct SavedTranslationsView: View {
    @Binding var savedTranslations: [String]
    @State private var translationsFromFirestore: [String] = []
    let firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            List {
                ForEach(translationsFromFirestore + savedTranslations, id: \.self) { translation in
                    Text(translation)
                }
                .onDelete(perform: deleteTranslation)
            }
            .onAppear {
                fetchFirestoreTranslations()
            }
            
            Button("Erase All Translations") {
                savedTranslations.removeAll()
                firestoreService.deleteAllTranslations()
                translationsFromFirestore.removeAll()
            }
            .foregroundColor(.red)
            .padding()
        }
        .navigationTitle("Saved Translations")
    }
    
    func deleteTranslation(at offsets: IndexSet) {
        savedTranslations.remove(atOffsets: offsets)
    }
    
    func fetchFirestoreTranslations() {
        firestoreService.fetchTranslations { translations in
            self.translationsFromFirestore = translations
        }
    }
}
