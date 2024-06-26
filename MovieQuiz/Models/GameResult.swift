import Foundation

struct GameResult: Codable, Equatable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        return correct > another.correct || (correct == another.correct && total < another.total)
    }
}
