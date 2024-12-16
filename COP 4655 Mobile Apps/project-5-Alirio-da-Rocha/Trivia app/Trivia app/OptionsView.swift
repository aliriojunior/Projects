import SwiftUI

struct OptionsView: View {
    @Binding var isGameStarted: Bool
    @Binding var triviaQuestions: [TriviaQuestion]
    var startGame: (Int, String, String, String) -> Void

    @State private var numQuestions = "10"
    @State private var selectedCategory = "9"
    @State private var selectedDifficulty = "easy"
    @State private var selectedType = "multiple"

    var body: some View {
        Form {
            // Display name and student ID at the top
            Section {
                Text("Alirio da Rocha")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("Student ID: Z23335350")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Section(header: Text("Number of Questions")) {
                TextField("Enter number of questions", text: $numQuestions)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("Category")) {
                Picker("Category", selection: $selectedCategory) {
                    Text("General Knowledge").tag("9")
                    Text("Science & Nature").tag("17")
                    Text("History").tag("23")
                    Text("Sports").tag("21")
                    Text("Geography").tag("22")
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Section(header: Text("Difficulty")) {
                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("Easy").tag("easy")
                    Text("Medium").tag("medium")
                    Text("Hard").tag("hard")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Type of Questions")) {
                Picker("Type", selection: $selectedType) {
                    Text("Multiple Choice").tag("multiple")
                    Text("True / False").tag("boolean")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("Start Game") {
                if let amount = Int(numQuestions) {
                    startGame(amount, selectedCategory, selectedDifficulty, selectedType)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
