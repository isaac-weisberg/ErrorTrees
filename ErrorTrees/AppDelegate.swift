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

        window.rootViewController = controller

        window.makeKeyAndVisible()

        controller.viewModel = MainViewModel(deps: dependencies, temperatureRange: -10...25)

        return true
    }
}
