import RxFlow
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dependencies: HasAllDependencies!
    let flowCoordinator = FlowCoordinator()
    var flow: MainCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        dependencies = DependenciesDefault()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let controller = MainViewController.instantiate()

        controller.viewModel = MainViewModel(deps: dependencies, temperatureRange: -10...25)

        window.rootViewController = controller

        window.makeKeyAndVisible()

        flow = MainCoordinator(controller: controller)
        flowCoordinator.coordinate(flow: flow, with: controller.viewModel)

        return true
    }
}
