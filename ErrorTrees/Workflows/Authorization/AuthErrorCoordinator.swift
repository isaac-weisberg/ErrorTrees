import RxSwift
import CeylonYellow

class AuthErrorCoordinator: Coordinator<Void> {
    let controller: UIViewController
    let error: AuthErrorModelRepresentable

    init(controller: UIViewController, error: AuthErrorModelRepresentable) {
        self.controller = controller
        self.error = error
    }

    override func start() -> Single<Void> {
        return Single.deferred { [unowned controller, error] in
            let authController = AuthErrorController.instantiate()

            authController.viewModel = AuthErrorViewModel(presenter: error)

            controller.present(authController, animated: true)

            return authController.viewModel.logIn
                .take(1)
                .asSingle()
        }
    }
}
