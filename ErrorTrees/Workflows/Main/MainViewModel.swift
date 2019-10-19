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
    let minorError: Observable<ErrorSingularRepresentable?>
    let majorError: Observable<ErrorTitledSingularRepresentable>
    let authError: Observable<AuthErrorModelRepresentable>

    let forecastRequested = PublishSubject<Void>()

    init(deps: Deps, temperatureRange: ClosedRange<Double>) {
        let scheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

        typealias ForecastDownloadResult = Result<ForecastDTO, BusinessLogicError>

        struct InternalState {
            let temperature: TemperatureState
            let lastResult: ForecastDownloadResult?
        }

        let initialState = InternalState(temperature: .unknown, lastResult: nil)

        let forecast = forecastRequested
            .observeOn(scheduler)
            .flatMapLatest { _ in
                deps.forecastDownloader.downloadForecast(from: url)
            }
            .scan(initialState) { internalState, result in
                let result = result
                    .mapError { error in
                        BusinessLogicError.downloadError(error)
                    }
                    .flatMap { forecast -> ForecastDownloadResult in
                        let temperature = forecast.temperature
                        guard temperatureRange.contains(temperature) else {
                            return .failure(BusinessLogicError.temperatureInvalid(temperature))
                        }
                        return .success(forecast)
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
            .startWith(initialState)
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)

        temperature = forecast
            .map { state in
                state.temperature
            }

        minorError = forecast
            .map { result in
                switch result.lastResult {
                case .failure(let outerReason):
                    switch outerReason {
                    case .downloadError(let reason):
                        switch reason {
                        case .download(let reason):
                            switch reason {
                            case .networkError:
                                return outerReason
                            case .invalidResponseType, .noData, .unexpectedStatusCode, .unauthorized:
                                return nil
                            }
                        case .parsing:
                            return nil
                        }
                    case .temperatureInvalid:
                        return nil
                    }
                case .success, .none:
                    return nil
                }
            }

        majorError = forecast
            .map { result -> ErrorTitledSingularRepresentable? in
                switch result.lastResult {
                case .none, .success:
                    return nil
                case .failure(let outerReason):
                    switch outerReason {
                    case .downloadError(let reason):
                        switch reason {
                        case .parsing:
                            return outerReason
                        case .download(let reason):
                            switch reason {
                            case .noData, .invalidResponseType, .unexpectedStatusCode:
                                return outerReason
                            case .networkError, .unauthorized:
                                return nil
                            }
                        }
                    case .temperatureInvalid:
                        return outerReason
                    }
                }
            }
            .filter { $0 != nil }.map { $0! }

        authError = forecast
            .map { result -> AuthErrorModelRepresentable? in
                switch result.lastResult {
                case .none, .success:
                    return nil
                case .failure(let reason):
                    switch reason {
                    case .downloadError(let reason):
                        switch reason {
                        case .download(let reason):
                            switch reason {
                            case .unauthorized:
                                return AuthErrorFromMain()
                            case .networkError, .invalidResponseType, .noData, .unexpectedStatusCode:
                                return nil
                            }
                        case .parsing:
                            return nil
                        }
                    case .temperatureInvalid:
                        return nil
                    }
                }
            }
            .filter { $0 != nil }.map { $0! }
    }
}

extension BusinessLogicError: ErrorTitledSingularRepresentable {
    var errorTitledSingular: ErrorTitledSingularType {
        switch self {
        case .temperatureInvalid(let temp):
            return ErrorTitledSingular("No wait", "\(temp) doesn't seem quite right")
        case .downloadError(let reason):
            return reason.errorTitledSingular
        }
    }
}

extension BusinessLogicError: ErrorSingularRepresentable {
    var errorSingular: ErrorSingularType {
        return errorTitledSingular.singularDescription
    }
}

/*used in a gist*/
private func asdf() {
        let newForecastRecieved: Observable<Result<ForecastDTO, BusinessLogicError>> = .never()

        let minorError = newForecastRecieved
            .map { result -> String? in
                switch result {
                case .failure(let reason):
                    switch reason {
                    case .downloadError(let reason):
                        switch reason {
                        case .download(let reason):
                            switch reason {
                            case .networkError(let reason):
                                return reason.localizedDescription
                            case .invalidResponseType, .noData, .unexpectedStatusCode, .unauthorized:
                                return nil
                            }
                        case .parsing:
                            return nil
                        }
                    case .temperatureInvalid:
                        return nil
                    }
                case .success:
                    return nil
                }
            }
}
