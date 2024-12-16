import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var translations: [(language: String, text: String)] = []
    @State private var savedTranslations: [String] = []
    let firestoreService = FirestoreService() // Firestore service for saving translations
    
    // List of languages to translate into
    let targetLanguages = [
        "es": "Spanish",
        "fr": "French",
        "de": "German",
        "it": "Italian",
        "pt": "Portuguese"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter text", text: $inputText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: translateText) {
                    Text("Translate Me")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Translations Box
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(translations, id: \.language) { translation in
                            Text("\(translation.language): \(translation.text)")
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1)) // Light gray background
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                
                NavigationLink("View Saved Translations", destination: SavedTranslationsView(savedTranslations: $savedTranslations))
                    .padding()
                
                Spacer()
                
                Text("Alirio Da Rocha Z23335350")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom)

            }
            .padding()
            .navigationTitle("Translate Me")
        }
    }
    
    func translateText() {
        guard !inputText.isEmpty else {
            translations = [("Error", "Please enter text to translate.")]
            return
        }
        
        translations = [] // Clear previous translations
        
        for (languageCode, languageName) in targetLanguages {
            // Encode the input text to make it URL-safe
            guard let encodedText = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                DispatchQueue.main.async {
                    self.translations.append((languageName, "Invalid input text."))
                }
                return
            }
            
            // Construct the API URL with the encoded input
            let apiUrl = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=en|\(languageCode)"
            
            // Create the URL object
            guard let url = URL(string: apiUrl) else {
                DispatchQueue.main.async {
                    self.translations.append((languageName, "Invalid API URL."))
                }
                return
            }
            
            // Create the URLSession data task
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.translations.append((languageName, "Error: \(error.localizedDescription)"))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.translations.append((languageName, "No data received."))
                    }
                    return
                }
                
                // Parse the JSON response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let responseData = json["responseData"] as? [String: Any],
                       let translation = responseData["translatedText"] as? String {
                        DispatchQueue.main.async {
                            self.translations.append((languageName, translation))
                            if !self.inputText.isEmpty {
                                let fullTranslation = "\(self.inputText) → \(languageName): \(translation)"
                                self.savedTranslations.append(fullTranslation)
                                firestoreService.saveTranslation(input: self.inputText, translation: "\(languageName): \(translation)")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.translations.append((languageName, "Failed to parse translation."))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.translations.append((languageName, "Error: \(error.localizedDescription)"))
                    }
                }
            }
            
            task.resume()
        }
    }
}
