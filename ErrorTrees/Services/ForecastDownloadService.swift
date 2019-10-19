import RxSwift

enum ForecastDownloadError: Error {
    case download(DataDownloadServiceError)
    case parsing(Error)
}

extension ForecastDownloadError: ErrorTitledSingularRepresentable {
    var errorTitledSingular: ErrorTitledSingularType {
        switch self {
        case .parsing:
            return ErrorTitledSingular("Dang it", "There was a problem decoding the forecast")
        case .download(let reason):
            return reason.errorTitledSingular
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
        let rand = (0..<6).randomElement()
        if rand == 5 {
            return .just(.success(ForecastDTO(temperature: 12)))
        }
        if rand == 0 {
            return .just(.success(ForecastDTO(temperature: 9000)))
        }
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
