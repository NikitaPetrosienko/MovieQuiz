import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let alertIdentifier: String
    let buttonIdentifier: String
    let completion: () -> Void
}
