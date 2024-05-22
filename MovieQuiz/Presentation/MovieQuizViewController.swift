import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        self.questionFactory = QuestionFactory()
        questionFactory?.setup(delegate: self)
        questionFactory?.requestNextQuestion()

        self.statisticService = StatisticService()
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
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz viewModel: QuizStepViewModel) {
        textLabel.text = viewModel.question
        imageView.image = viewModel.image
        counterLabel.text = viewModel.questionNumber
    }
    
    private func showQuizResults() {
        let gamesCount = statisticService?.gamesCount ?? 0
        let bestGame = statisticService?.bestGame
        let totalAccuracy = statisticService?.totalAccuracy ?? 0.0

        let message = """
        Вы завершили викторину!
        Сыграно игр: \(gamesCount)
        Лучший результат: \(bestGame?.correct ?? 0) из \(bestGame?.total ?? 0) на дату \(bestGame?.date.formatted(date: .abbreviated, time: .omitted) ?? "").
        Средняя точность: \(String(format: "%.2f", totalAccuracy))%
        """
        
        alertPresenter?.showResultAlert(title: "Результаты", message: message, buttonText: "ОК") { [weak self] in
            self?.resetQuiz()
        }
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
        let greenColor = UIColor(named: "YP Green", in: Bundle.main, compatibleWith: nil) ?? UIColor.green
        let redColor = UIColor(named: "YP Red", in: Bundle.main, compatibleWith: nil) ?? UIColor.red
        
        print("Green Color: \(greenColor)")  // Добавьте это для отладки
        print("Red Color: \(redColor)")      // Добавьте это для отладки
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? greenColor.cgColor : redColor.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.imageView.layer.borderWidth = 0
            self?.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            showQuizResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
