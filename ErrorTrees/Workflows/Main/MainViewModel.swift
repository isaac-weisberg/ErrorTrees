import RxSwift

private let url = URL(string: "http://lolshock.com")!

private enum BusinessLogicError: Error {
    case downloadError(JsonDownloadServiceError)
    case temperatureInvalid(Double)
}

struct MainViewModel {
    typealias Deps = HasJsonDownloadService

    enum TemperatureState {
        case unknown
        case temperature(Double)
        case lastKnownTemperature(Double)
    }

    let temperature: Observable<TemperatureState>

    let forecastRequested = PublishSubject<Void>()

    init(deps: Deps, temperatureRange: ClosedRange<Double>) {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

        let forecast = {
            deps.jsonDownloader.downloadJson(from: url)
                .mapError { error -> BusinessLogicError in
                    .downloadError(error)
            }
            .flatMap { (forecast: ForecastDTO) -> Result<ForecastDTO, BusinessLogicError> in
                let temperature = forecast.temperature
                guard temperatureRange.contains(temperature) else {
                    return.failure(BusinessLogicError.temperatureInvalid(temperature))
                }
                return .success(forecast)
            }
        }

        let forecastArrived = forecastRequested
            .observeOn(scheduler)
            .map { _ in
                forecast()
            }
            .observeOn(MainScheduler.asyncInstance)
            .share()

        temperature = forecastArrived
            .scan(TemperatureState.unknown) { state, result in
                switch result {
                case .success(let forecast):
                    return .temperature(forecast.temperature)
                case .failure:
                    switch state {
                    case .unknown:
                        return .unknown
                    case .temperature(let temp), .lastKnownTemperature(let temp):
                        return .lastKnownTemperature(temp)
                    }
                }
            }
    }
}
