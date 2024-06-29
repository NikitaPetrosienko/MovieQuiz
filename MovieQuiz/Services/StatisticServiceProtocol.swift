import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get set }
    var bestGame: StatisticService.GameResult { get set }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
