import UIKit

protocol AuthErrorModelType {
    var title: String { get }

    var description: String { get }

    var image: UIImage { get }
}

struct AuthErrorModel: AuthErrorModelType {
    let title: String
    let description: String
    let image: UIImage
}

protocol AuthErrorModelRepresentable {
    var authErrorModel: AuthErrorModelType { get }
}
