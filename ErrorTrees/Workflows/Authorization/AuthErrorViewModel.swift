import RxCocoa
import RxFlow
import RxSwift

struct AuthErrorViewModel {
    let presenter: AuthErrorModelRepresentable

    let steps = PublishRelay<Step>()
}

extension AuthErrorViewModel: Stepper {
    func logIn() {
        steps.accept(MainCoordinator.Steps.logIn)
    }
}
