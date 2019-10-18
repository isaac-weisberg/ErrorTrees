import RxSwift

enum JsonDownloadServiceError: Error {
    case download(Error)
    case decoding(Error)
}

struct JsonDownloadService {
    func downloadJson<Object: Decodable>(from url: URL) -> Result<Object, JsonDownloadServiceError> {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            return .failure(.download(error))
        }

        let object: Object

        do {
            object = try JSONDecoder().decode(Object.self, from: data)
        } catch {
            return .failure(.decoding(error))
        }
        return .success(object)
    }

    init() {
        
    }
}
