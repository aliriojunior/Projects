import Foundation

// Root response model for the trivia API
struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

// Model for each trivia question
struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()  // Unique identifier for SwiftUI lists
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    var userSelectedAnswer: String? = nil  // Stores the user's answer selection

    // Combines and shuffles all answers for display
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
    
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
