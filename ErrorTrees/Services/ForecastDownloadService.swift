import RxSwift

enum ForecastDownloadError: Error {
    case download(DataDownloadServiceError)
    case parsing(Error)
}

class ForecastDownloadService {
    let dataDownloader: DataDownloadServiceProtocol

    init(dataDownloader: DataDownloadServiceProtocol) {
        self.dataDownloader = dataDownloader
    }

    func downloadForecast(from url: URL) -> Single<Result<ForecastDTO, ForecastDownloadError>> {
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