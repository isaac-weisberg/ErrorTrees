import RxSwift

private let url = URL(string: "https://apple.com")!

private enum BusinessLogicError: Error {
    case downloadError(DataDownloadServiceError)
    case temperatureInvalid(Double)
}

struct MainViewModel {
    typealias Deps = HasForecastDownloadService

    enum TemperatureState {
        case unknown
        case temperature(Double)
        case lastKnownTemperature(Double)
    }

    let temperature: Observable<TemperatureState>

    let forecastRequested = PublishSubject<Void>()

    init(deps: Deps, temperatureRange: ClosedRange<Double>) {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

        temperature = forecastRequested
            .observeOn(scheduler)
            .flatMapLatest { _ in
                deps.forecastDownloader.downloadForecast(from: url)
            }
            .debug()
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
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
    }
}
