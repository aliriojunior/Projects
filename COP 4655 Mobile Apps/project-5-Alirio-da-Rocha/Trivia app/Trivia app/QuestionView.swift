import SwiftUI

struct QuestionView: View {
    @Binding var question: TriviaQuestion  // Binding to allow updates to the selected answer

    var body: some View {
        VStack(alignment: .leading) {
            Text(question.question)
                .font(.headline)
                .padding(.bottom, 5)
            
            // Render each answer option
            ForEach(question.allAnswers, id: \.self) { answer in
                Button(action: {
                    question.userSelectedAnswer = answer  // Update the question's selected answer
                    print("Selected answer: \(answer) for question: \(question.question)")
                }) {
                    HStack {
                        Text(answer)
                            .padding()
                        Spacer()
                        if question.userSelectedAnswer == answer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(question.userSelectedAnswer == answer ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}
