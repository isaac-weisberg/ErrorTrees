import RxSwift

struct AuthViewModel {
    let presenter: AuthErrorModelRepresentable

    let logIn = PublishSubject<Void>()
}
