import RxSwift

enum DataDownloadServiceError: Error {
    case unexpectedStatusCode(Int)
    case noData
    case networkError(Error)
    case invalidResponseType
}

typealias DataDownloadResult = Single<Result<Data, DataDownloadServiceError>>

protocol DataDownloadServiceProtocol {
    func download(from url: URL) -> DataDownloadResult
}

extension DataDownloadServiceError: ErrorSinglularRepresentable {
    var errorSingular: ErrorSingularType {
        switch self {
        case .noData:
            return "The server must be hung over tbh"
        case .invalidResponseType:
            return "Ooops, guess we've goofed up"
        case .networkError(let error):
            return "There was a network error"

            return error.localizedDescription // used in gist
        case .unexpectedStatusCode(let code):
            return "The server has responded with status code \(code)-- no idea like-- what?"
        }
    }
}

struct DataDownloadServiceStub: DataDownloadServiceProtocol {
    func download(from url: URL) -> DataDownloadResult {
        return Single.deferred {
            let random = Int.random(in: 0..<4)

            let failure = { () -> DataDownloadServiceError in
                switch random {
                case 0:
                    return .noData
                case 1:
                    return .networkError(NSError(domain: "com.apple.urlsession.datatask.stub", code: 420, userInfo: nil))
                case 2:
                    return .unexpectedStatusCode(69)
                default:
                    return .invalidResponseType
                }
            }()

            return .just(.failure(failure))
        }
    }
}
