import RxSwift
import RxCocoa

func download(from url: URL) -> Single<Data> { return .never() }

func parse<Target: Decodable>(json data: Data) -> Single<Target> { return .never() }


func downloadJson<Target: Decodable>(from url: URL) -> Single<Target> {
    return download(from: url)
        .flatMap { data in
            parse(json: data)
        }
}
