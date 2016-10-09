import Foundation
import RxSwift
import RxCocoa
import JASON

typealias GifResultPage = (offset: Int, limit: Int)

protocol GifGate {
    func searchGifs(query: String, page: GifResultPage) -> Observable<[Gif]>
    func fetchTrending(limit: Int) -> Observable<[Gif]>
}

enum GifGateError: Error {
    case parsingFailed
}

final class GifGateway: GifGate {
    private let session: URLSession
    private let urlComponents: URLComponents
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        session = URLSession(configuration: configuration)
        
        var urlComponents = URLComponents(string: "https://api.giphy.com/v1/gifs")!
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: "dc6zaTOxFJmzC")]
        self.urlComponents = urlComponents
    }
    
    func searchGifs(query: String, page: GifResultPage) -> Observable<[Gif]> {
        return fetchGifs(path: "/search", params: ["q": query], page: page)
    }
    
    func fetchTrending(limit: Int) -> Observable<[Gif]> {
        return fetchGifs(path: "/trending", params: [:], page: (offset: 0, limit: limit))
    }
    
    private func fetchGifs(path: String, params: [String: String], page: GifResultPage) -> Observable<[Gif]> {
        var urlParams = params
        urlParams["offset"] = String(page.offset)
        urlParams["limit"] = String(page.limit)
        return json(url(path: path, params: urlParams)) { $0["data"].map(Gif.init) }
    }
    
    private func json<T>(_ url: URL, parse: @escaping (JSON) -> T?) -> Observable<T> {
        return session.rx
            .JSON(url)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .background))
            .flatMap { result -> Observable<T> in
                guard let model = parse(JSON(result)) else { return Observable.error(GifGateError.parsingFailed) }
                return Observable.just(model)
        }
    }
    
    private func url(path: String, params: [String: String]) -> URL {
        var components = urlComponents
        components.path += path
        let queryItems = params.map { keyValue in URLQueryItem(name: keyValue.0, value: keyValue.1) }
        components.queryItems = queryItems + components.queryItems!
        return components.url!
    }
}
