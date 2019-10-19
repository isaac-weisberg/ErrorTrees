import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dependencies: HasAllDependencies!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        dependencies = DependenciesDefault()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let controller = MainViewController.instantiate()

        controller.viewModel = MainViewModel(deps: dependencies, temperatureRange: -10...25)

        controller.viewModel.authError
            .bind(onNext: { [unowned controller] error in
                let authController = AuthController.instantiate()

                authController.viewModel = AuthViewModel(presenter: error)

                authController.viewModel.logIn
                    .bind(onNext: { [unowned controller] _ in
                        controller.dismiss(animated: true)
                    })
                    .disposed(by: authController.disposeBag)

                controller.present(authController, animated: true)
            })
            .disposed(by: controller.disposeBag)

        window.rootViewController = controller

        window.makeKeyAndVisible()


        return true
    }
}
