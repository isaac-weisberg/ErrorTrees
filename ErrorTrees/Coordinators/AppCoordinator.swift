import RxSwift
import CeylonYellow

class AppCoordinator: Coordinator<Never> {
    typealias Deps = HasAllDependencies

    let window: UIWindow
    let deps: Deps

    init(window: UIWindow, deps: Deps) {
        self.window = window
        self.deps = deps
    }

    override func start() -> PrimitiveSequence<SingleTrait, Never> {
        return Single.deferred { [unowned self, window, deps] in
            let controller = MainViewController.instantiate()

            controller.viewModel = MainViewModel(deps: deps, temperatureRange: -10...25)

            controller.viewModel.authError
                .flatMapLatest { [unowned self, unowned controller] error -> Single<Void> in
                    let coordinator = AuthErrorCoordinator(controller: controller, error: error)
                    return self.startChild(coordinator)
                }
                .bind(onNext: { [unowned controller] _ in
                    controller.dismiss(animated: true)
                })
                .disposed(by: controller.disposeBag)

            window.rootViewController = controller

            return .never()
        }
    }
}
