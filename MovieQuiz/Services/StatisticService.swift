import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case bestGame
        case gamesCount
    }

    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }

    var bestGame: GameResult {
        get {
            if let data = storage.data(forKey: Keys.bestGame.rawValue),
               let gameResult = try? JSONDecoder().decode(GameResult.self, from: data) {
                return gameResult
            }
            return GameResult(correct: 0, total: 0, date: Date())
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                storage.set(data, forKey: Keys.bestGame.rawValue)
            }
        }
    }

    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        return totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) * 100 : 0
    }

    func store(correct count: Int, total amount: Int) {
        var currentCorrect = storage.integer(forKey: Keys.correctAnswers.rawValue)
        var currentTotal = storage.integer(forKey: Keys.totalQuestions.rawValue)
        currentCorrect += count
        currentTotal += amount
        storage.set(currentCorrect, forKey: Keys.correctAnswers.rawValue)
        storage.set(currentTotal, forKey: Keys.totalQuestions.rawValue)

        let newResult = GameResult(correct: count, total: amount, date: Date())
        let bestResult = bestGame
        if newResult.isBetterThan(bestResult) {
            bestGame = newResult
        }
        gamesCount += 1
    }
}
