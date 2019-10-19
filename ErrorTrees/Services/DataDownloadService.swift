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

struct DataDownloadServiceStub: DataDownloadServiceProtocol {
    func download(from url: URL) -> DataDownloadResult {
        return Single.deferred {
            let random = Int.random(in: 0..<4)

            let failure = { () -> DataDownloadServiceError in
                switch random {
                case 0:
                    return .noData
                case 1:
                    return .networkError(NSError(domain: "fuck.you", code: 420, userInfo: nil))
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
