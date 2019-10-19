import RxSwift

enum ForecastDownloadError: Error {
    case download(DataDownloadServiceError)
    case parsing(Error)
}

extension ForecastDownloadError: ErrorSinglularRepresentable {
    var errorSingular: ErrorSingularType {
        switch self {
        case .parsing:
            return "There was a problem decoding the forecast"
        case .download(let reason):
            return reason.errorSingular
        }
    }
}

typealias ForecastDownloadResult = Result<ForecastDTO, ForecastDownloadError>

class ForecastDownloadService {
    let dataDownloader: DataDownloadServiceProtocol

    init(dataDownloader: DataDownloadServiceProtocol) {
        self.dataDownloader = dataDownloader
    }

    func downloadForecast(from url: URL) -> Single<ForecastDownloadResult> {
        return dataDownloader.download(from: url)
            .map { result in
                result
                    .mapError { error in
                        ForecastDownloadError.download(error)
                    }
                    .flatMap { data in
                        let forecast: ForecastDTO
                        do {
                            forecast = try JSONDecoder().decode(ForecastDTO.self, from: data)
                        } catch {
                            return .failure(ForecastDownloadError.parsing(error))
                        }
                        return .success(forecast)
                    }
            }
    }
}
