import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()
    
    func saveTranslation(input: String, translation: String) {
        db.collection("translations").addDocument(data: [
            "input": input,
            "translation": translation,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error saving translation: \(error)")
            }
        }
    }
    
    func fetchTranslations(completion: @escaping ([String]) -> Void) {
        db.collection("translations").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching translations: \(error.localizedDescription)")
                completion([]) // Return an empty array if there's an error
                return
            }
            
            // Safely extract documents and convert them to [String]
            let translations: [String] = snapshot?.documents.compactMap { doc in
                guard let input = doc["input"] as? String,
                      let translation = doc["translation"] as? String else { return nil }
                return "\(input) → \(translation)"
            } ?? []
            
            completion(translations) // Pass the valid array of strings
        }
    }

    
    func deleteAllTranslations() {
        db.collection("translations").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching translations for deletion: \(error)")
                return
            }
            snapshot?.documents.forEach { $0.reference.delete() }
        }
    }
}
