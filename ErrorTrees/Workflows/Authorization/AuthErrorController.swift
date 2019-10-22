import RxSwift
import RxCocoa
import UIKit

class AuthErrorController: UIViewController {
    let disposeBag = DisposeBag()

    var viewModel: AuthErrorViewModel!

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
            .bind(onNext: { [unowned self] _ in
                self.viewModel.logIn()
            })
            .disposed(by: disposeBag)
    }
}

extension AuthErrorController {
    static func instantiate() -> AuthErrorController {
        return UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthErrorController") as! AuthErrorController
    }
}
