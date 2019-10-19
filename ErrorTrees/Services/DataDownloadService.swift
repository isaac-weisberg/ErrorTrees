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

extension DataDownloadServiceError: ErrorTitledSingularRepresentable {
    var errorTitledSingular: ErrorTitledSingularType {
        switch self {
        case .noData:
            return ErrorTitledSingular("Yikes!", "The server must be hung over tbh")
        case .invalidResponseType:
            return ErrorTitledSingular("Darn", "Ooops, guess we've goofed up")
        case .networkError(let error):
            return ErrorTitledSingular("Error", "There was a network error" ?? error.localizedDescription)
             // used in gist
        case .unexpectedStatusCode(let code):
            return ErrorTitledSingular("Failure", "The server has responded with status code \(code)-- no idea like-- what?")
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
