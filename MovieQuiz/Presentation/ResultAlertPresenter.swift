import Foundation
import UIKit

class ResultAlertPresenter {
    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showResultAlert(gamesCount: Int, bestGame: GameResult, totalAccuracy: Double) {
        let message = """
        Вы завершили викторину!
        Сыграно игр: \(gamesCount)
        Лучший результат: \(bestGame.correct) из \(bestGame.total) (\(bestGame.date))
        Средняя точность: \(String(format: "%.2f", totalAccuracy))%
        """
        let alert = UIAlertController(title: "Результаты", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
            // Сброс или другое действие после закрытия алерта
        })
        viewController?.present(alert, animated: true, completion: nil)
    }
}
