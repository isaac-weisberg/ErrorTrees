import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dependencies: HasAllDependencies!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        dependencies = DependenciesDefault()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let controller = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "MainViewController") as! MainViewController

        controller.viewModel = MainViewModel(deps: dependencies, temperatureRange: -10...25)

        window.rootViewController = controller

        window.makeKeyAndVisible()

        return true
    }
}
