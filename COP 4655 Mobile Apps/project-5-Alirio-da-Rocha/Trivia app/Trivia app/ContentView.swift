import SwiftUI

struct ContentView: View {
    @State private var isGameStarted = false
    @State private var triviaQuestions: [TriviaQuestion] = []
    @State private var showScore = false

    var body: some View {
        NavigationView {
            if isGameStarted {
                TriviaGameView(triviaQuestions: $triviaQuestions, showScore: $showScore)
            } else {
                OptionsView(isGameStarted: $isGameStarted, triviaQuestions: $triviaQuestions) { amount, category, difficulty, type in
                    fetchTrivia(amount: amount, category: category, difficulty: difficulty, type: type)
                }
            }
        }
        .alert(isPresented: $showScore) {
            Alert(
                title: Text("Game Over"),
                message: Text("Your score: \(calculateScore())/\(triviaQuestions.count)"),
                dismissButton: .default(Text("OK")) { resetGame() }
            )
        }
    }
    
    func fetchTrivia(amount: Int, category: String, difficulty: String, type: String) {
        TriviaAPI().fetchQuestions(amount: amount, category: category, difficulty: difficulty, type: type) { questions in
            if let questions = questions {
                DispatchQueue.main.async {
                    triviaQuestions = questions
                    isGameStarted = true
                }
            }
        }
    }
    
    func calculateScore() -> Int {
        triviaQuestions.filter { $0.userSelectedAnswer == $0.correctAnswer }.count
    }
    
    func resetGame() {
        isGameStarted = false
        triviaQuestions = []
    }
}
