protocol HasVoidService {

}

protocol HasJsonDownloadService {
    var jsonDownloader: JsonDownloadService { get }
}

typealias HasAllDependencies = HasVoidService
    & HasJsonDownloadService

class DependenciesDefault: HasAllDependencies {
    let jsonDownloader: JsonDownloadService

    init() {
        jsonDownloader = JsonDownloadService()
    }
}
