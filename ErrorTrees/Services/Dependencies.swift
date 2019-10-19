protocol HasVoidService {

}

protocol HasDataDownloadService {
    var dataDownloader: DataDownloadServiceProtocol { get }
}

protocol HasForecastDownloadService {
    var forecastDownloader: ForecastDownloadService { get }
}

typealias HasAllDependencies = HasVoidService
    & HasDataDownloadService
    & HasForecastDownloadService

class DependenciesDefault: HasAllDependencies {
    let dataDownloader: DataDownloadServiceProtocol
    let forecastDownloader: ForecastDownloadService

    init() {
        dataDownloader = DataDownloadServiceStub() //DataDownloadService(session: .shared)
        forecastDownloader = ForecastDownloadService(dataDownloader: dataDownloader)
    }
}
