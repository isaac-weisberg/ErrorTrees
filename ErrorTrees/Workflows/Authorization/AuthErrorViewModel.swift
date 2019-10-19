import RxSwift

struct AuthErrorViewModel {
    let presenter: AuthErrorModelRepresentable

    let logIn = PublishSubject<Void>()
}
