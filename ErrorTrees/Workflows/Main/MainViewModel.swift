import RxSwift

private let url = URL(string: "https://apple.com")!

private enum BusinessLogicError: Error {
    case downloadError(ForecastDownloadError)
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
    let minorError: Observable<ErrorSinglularRepresentable?>

    let forecastRequested = PublishSubject<Void>()

    init(deps: Deps, temperatureRange: ClosedRange<Double>) {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

        typealias ForecastDownloadResult = Result<ForecastDTO, BusinessLogicError>

        struct InternalState {
            let temperature: TemperatureState
            let lastResult: ForecastDownloadResult?
        }

        let forecast = forecastRequested
            .observeOn(scheduler)
            .flatMapLatest { _ in
                deps.forecastDownloader.downloadForecast(from: url)
            }
            .scan(InternalState(temperature: .unknown, lastResult: nil)) { internalState, result in
                let result = result
                    .mapError { error in
                        BusinessLogicError.downloadError(error)
                    }

                let temperatureState = { () -> TemperatureState in
                    switch result {
                    case .success(let forecast):
                        return .temperature(forecast.temperature)
                    case .failure:
                        switch internalState.temperature {
                        case .unknown:
                            return .unknown
                        case .temperature(let temp), .lastKnownTemperature(let temp):
                            return .lastKnownTemperature(temp)
                        }
                    }
                }()

                return InternalState(temperature: temperatureState, lastResult: result)
            }
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)

        temperature = forecast
            .map { state in
                state.temperature
            }

        minorError = forecast
            .map { result in
                switch result.lastResult {
                case .failure(let reason):
                    return reason
                case .success:
                    return nil
                case .none:
                    return nil
                }
            }
    }
}

extension BusinessLogicError: ErrorSinglularRepresentable {
    var errorSingular: ErrorSingularType {
        return "Fuck"
    }
}
