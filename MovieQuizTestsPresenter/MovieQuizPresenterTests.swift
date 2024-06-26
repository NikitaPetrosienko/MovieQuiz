import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let questionFactoryMock = QuestionFactoryMock()
        let statisticServiceMock = StatisticServiceMock()

        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        sut.configure(with: questionFactoryMock, statisticService: statisticServiceMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
