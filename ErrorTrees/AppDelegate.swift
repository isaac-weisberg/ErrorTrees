import RxSwift
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dependencies: HasAllDependencies!

    var coordinator: AppCoordinator!
    var subscription: Disposable!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        dependencies = DependenciesDefault()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.makeKeyAndVisible()

        coordinator = AppCoordinator(window: window, deps: dependencies)

        subscription = coordinator
            .start()
            .subscribe()

        return true
    }
}
