import RxSwift
import RxCocoa
import UIKit

class AuthController: UIViewController {
    let disposeBag = DisposeBag()

    var viewModel: AuthViewModel!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var logInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let error = viewModel.presenter.authErrorModel

        titleLabel.text = error.title
        descriptionLabel.text = error.description
        imageView.image = error.image

        logInButton.rx.tap
            .bind(to: viewModel.logIn)
            .disposed(by: disposeBag)
    }
}

extension AuthController {
    static func instantiate() -> AuthController {
        return UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthController") as! AuthController
    }
}
