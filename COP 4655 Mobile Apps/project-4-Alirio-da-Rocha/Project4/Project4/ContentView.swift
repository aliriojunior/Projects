import SwiftUI

struct ContentView: View {
    // Pair options, selected pairs, cards, and selected indices
    private let pairOptions = [2, 4, 6, 8]
    @State private var selectedPairs = 4
    @State private var cards: [Card] = []
    @State private var selectedIndices: [Int] = []
    
    // Score tracking and win alert state
    @State private var score = 0
    @State private var showWinAlert = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            ZStack {
                Color.green.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Score display
                    Text("Score: \(score)")
                        .font(.title)
                        .padding()

                    // Pair selection picker
                    Picker("Number of Pairs", selection: $selectedPairs) {
                        ForEach(pairOptions, id: \.self) { option in
                            Text("\(option) Pairs").tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: selectedPairs) {
                        initializeGame() // Simplified closure, no parameters needed
                    }
	

                    // Scrollable card grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(cards.indices, id: \.self) { index in
                                CardView(card: $cards[index])
                                    .onTapGesture {
                                        handleCardTap(at: index)
                                    }
                            }
                        }
                        .padding()
                    }

                    // Reset game button with styling
                    Button(action: resetGame) {
                        Text("Reset Game")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            // Display name and ID at the bottom
            Text("Alirio da Rocha Z23335350")
                .font(.footnote)
                .padding(.top, 20)
        }
        .onAppear(perform: initializeGame)
        .alert(isPresented: $showWinAlert) {
            Alert(
                title: Text("You Win!"),
                message: Text("Congratulations! You matched all pairs!"),
                dismissButton: .default(Text("Play Again")) {
                    resetGame()
                }
            )
        }
    }

    // Function to initialize the game with the selected number of pairs
    func initializeGame() {
        let availableEmojis = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼"]
        let selectedEmojis = Array(availableEmojis.prefix(selectedPairs))
        let newCards = (selectedEmojis + selectedEmojis).map { Card(content: $0) }.shuffled()
        cards = newCards
        selectedIndices.removeAll()
        score = 0 // Reset score when the game is initialized
    }

    func handleCardTap(at index: Int) {
        if cards[index].isMatched || cards[index].isFaceUp || selectedIndices.count == 2 {
            return
        }
        
        withAnimation(.easeInOut) {
            cards[index].isFaceUp = true
        }
        selectedIndices.append(index)

        if selectedIndices.count == 2 {
            checkForMatch()
        }
    }
    
    func checkForMatch() {
        let firstIndex = selectedIndices[0]
        let secondIndex = selectedIndices[1]
        
        if cards[firstIndex].content == cards[secondIndex].content {
            withAnimation(.easeInOut) {
                cards[firstIndex].isMatched = true
                cards[secondIndex].isMatched = true
            }
            score += 1 // Increment score for a match
            checkForWin() // Check if the player has won
            selectedIndices.removeAll()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut) {
                    cards[firstIndex].isFaceUp = false
                    cards[secondIndex].isFaceUp = false
                }
                selectedIndices.removeAll()
            }
        }
    }
    
    // Function to check if all pairs are matched and trigger the win alert
    func checkForWin() {
        if cards.allSatisfy({ $0.isMatched }) {
            showWinAlert = true
        }
    }

    func resetGame() {
        initializeGame()
    }
}
