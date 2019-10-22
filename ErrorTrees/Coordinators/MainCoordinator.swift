import RxFlow

class MainCoordinator: Flow {
    var root: Presentable {
        return controller
    }

    let controller: MainViewController

    func navigate(to step: Step) -> FlowContributors {
        let step = step as! Steps

        switch step {
        case .authError(let error):
            let authController = AuthErrorController.instantiate()

            authController.viewModel = AuthErrorViewModel(presenter: error)

            controller.present(authController, animated: true)
            return .one(flowContributor: .contribute(withNextPresentable: authController, withNextStepper: authController.viewModel))
        case .logIn:
            controller.dismiss(animated: true)
            return .one(flowContributor: .contribute(withNextPresentable: controller, withNextStepper: controller.viewModel))
        }
    }

    enum Steps: Step {
        case authError(AuthErrorModelRepresentable)
        case logIn
    }

    init(controller: MainViewController) {
        self.controller = controller
    }
}
