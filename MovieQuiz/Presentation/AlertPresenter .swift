import UIKit

class AlertPresenter {
    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showResultAlert(result: AlertModel) {
        let alert = UIAlertController(title: result.title, message: result.message, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        alert.addAction(action)
        
        // Установим идентификатор на действие (кнопку) внутри UIAlertController
        action.accessibilityIdentifier = result.buttonIdentifier
        viewController?.present(alert, animated: true, completion: nil)
        
        // Установим идентификатор на сам UIAlertController после его представления
        DispatchQueue.main.async {
            alert.view.accessibilityIdentifier = result.alertIdentifier
        }
    }
}
