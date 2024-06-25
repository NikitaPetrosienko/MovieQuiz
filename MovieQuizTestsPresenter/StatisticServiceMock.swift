import Foundation
@testable import MovieQuiz

class StatisticServiceMock: StatisticServiceProtocol {
    var totalAccuracy: Double = 0.0
    var gamesCount: Int = 0
    var bestGame: GameResult = GameResult(correct: 0, total: 0, date: Date())

    func store(correct count: Int, total amount: Int) {
        // Моковая реализация
    }
}
