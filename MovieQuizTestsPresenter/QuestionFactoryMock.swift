import Foundation
@testable import MovieQuiz

class QuestionFactoryMock: QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate?

    func loadData() {
        // Моковая реализация
    }

    func requestNextQuestion() {
        // Моковая реализация
    }
}
