import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenter?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showResultAlert(result: model)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        showLoadingIndicator()
        questionFactory?.loadData()
        self.alertPresenter = AlertPresenter(viewController: self)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func show(quiz viewModel: QuizStepViewModel) {
        textLabel.text = viewModel.question
        imageView.image = viewModel.image
        counterLabel.text = viewModel.questionNumber
    }

    private func showQuizResults() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)

        let gamesCount = statisticService?.gamesCount ?? 0
        let bestGame = statisticService?.bestGame
        let totalAccuracy = statisticService?.totalAccuracy ?? 0.0

        let bestGameDate = bestGame?.date.formatted(date: .numeric, time: .shortened) ?? ""
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGame?.correct ?? 0)/\(bestGame?.total ?? 0) (\(bestGameDate))
        Средняя точность: \(String(format: "%.2f", totalAccuracy))%
        """

        let resultModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз") { [weak self] in
                self?.resetQuiz()
            }

        alertPresenter?.showResultAlert(result: resultModel)
    }

    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
    }

    private func checkAnswer(_ answer: Bool) {
        guard let question = currentQuestion else { return }
        let isCorrect = question.correctAnswer == answer
        correctAnswers += isCorrect ? 1 : 0
        showAnswerResult(isCorrect: isCorrect)
    }

    private func showAnswerResult(isCorrect: Bool) {
        print("Green Color: \(UIColor.ypGreen)")
        print("Red Color: \(UIColor.ypRed)")

        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.imageView.layer.borderWidth = 0
            self?.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator() // Скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // Возьмём в качестве сообщения описание ошибки
    }
}
