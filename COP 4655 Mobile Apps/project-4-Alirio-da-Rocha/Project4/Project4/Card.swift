import Foundation

struct Card: Identifiable {
    var id = UUID()
    var content: String
    var isFaceUp = false
    var isMatched = false
}
