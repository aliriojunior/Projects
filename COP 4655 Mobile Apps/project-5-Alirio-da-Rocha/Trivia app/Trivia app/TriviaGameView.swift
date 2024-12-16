import SwiftUI

struct TriviaGameView: View {
    @Binding var triviaQuestions: [TriviaQuestion]
    @Binding var showScore: Bool

    var body: some View {
        VStack {
            ScrollView {
                ForEach($triviaQuestions) { $question in
                    QuestionView(question: $question)
                }
            }
            
            Button("Submit Answers") {
                showScore = true
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
