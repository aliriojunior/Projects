import Foundation

class TriviaAPI {
    func fetchQuestions(amount: Int, category: String, difficulty: String, type: String, completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=\(amount)&category=\(category)&difficulty=\(difficulty)&type=\(type)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching trivia questions:", error)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                completion(triviaResponse.results)
            } catch {
                print("Error decoding JSON:", error)
                completion(nil)
            }
        }.resume()
    }
}
