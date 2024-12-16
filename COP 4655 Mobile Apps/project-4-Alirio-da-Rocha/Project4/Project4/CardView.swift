import SwiftUI

struct CardView: View {
    @Binding var card: Card

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .animation(.easeInOut, value: card.isFaceUp)
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 2)
                if !card.isMatched {
                    Text(card.content)
                        .font(.largeTitle)
                        .opacity(card.isFaceUp ? 1 : 0)
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
            }
        }
        .frame(width: 70, height: 100)
        .opacity(card.isMatched ? 0.5 : 1)
        .animation(.easeInOut, value: card.isMatched)
    }
}
