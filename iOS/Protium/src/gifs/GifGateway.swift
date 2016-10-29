import Foundation
import RxSwift
import RxCocoa
import JASON

typealias GifPage = (offset: Int, limit: Int)
typealias GifList = (items: [Gif], totalCount: Int)

// Protocol that is also implemented by GifStubGateway (see Tests).
// Each methods returns an Observable, which allows for chaining calls, mapping results etc.
protocol GifGate {
    func searchGifs(query: String, page: GifPage) -> Observable<GifList>
    func fetchTrendingGifs(limit: Int) -> Observable<GifList>
}

enum GifGateError: Error {
    case parsingFailed
}

// This Gateway simply uses URLSession and its Rx extension.
// You might want to use your favorite networking stack here...
final class GifGateway: GifGate {
    private let reachabilityService: ReachabilityService
    private let session: URLSession
    private let urlComponents: URLComponents
    
    init(reachabilityService: ReachabilityService) {
        self.reachabilityService = reachabilityService
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        session = URLSession(configuration: configuration)
       
        // Base URLs, API Keys etc. would normally be passed in via initialized parameters 
        // but are hard-coded here for demo purposes.
        var urlComponents = URLComponents(string: "https://api.giphy.com/v1/gifs")!
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: "dc6zaTOxFJmzC")]
        self.urlComponents = urlComponents
    }
    
    // MARK: - Public API
    
    func searchGifs(query: String, page: GifPage) -> Observable<GifList> {
        return fetchGifs(path: "/search", params: ["q": query], page: page)
    }
    
    func fetchTrendingGifs(limit: Int) -> Observable<GifList> {
        return fetchGifs(path: "/trending", params: [:], page: (offset: 0, limit: limit))
    }
    
    // MARK: - Private Methods
    
    // Fetches a page of gifs. The JSON response is parsed into Model objects and wrapped into an Observable.
    private func fetchGifs(path: String, params: [String: String], page: GifPage) -> Observable<GifList> {
        var urlParams = params
        urlParams["offset"] = String(page.offset)
        urlParams["limit"] = String(page.limit)
        
        return json(url(path: path, params: urlParams)) { json in
            let items = json["data"].map(Gif.init)
            let pagination = json["pagination"]
            let totalCount = (pagination["total_count"].int ?? pagination["count"].int) ?? items.count
            return (items, totalCount)
        }
    }
   
    // Performs the actual call on URLSession, retries on failure and performs the parsing on a background queue.
    private func json<T>(_ url: URL, parse: @escaping (JSON) -> T?) -> Observable<T> {
        return session.rx
            .json(url: url)
            .retry(1)
            .retryOnBecomesReachable(url, reachabilityService: reachabilityService)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { result in
                guard let model = parse(JSON(result)) else { throw GifGateError.parsingFailed }
                return model
        }
    }
   
    // Constructs the complete URL based on the base url components, the passed in path and params.
    private func url(path: String, params: [String: String]) -> URL {
        var components = urlComponents
        components.path += path
        let queryItems = params.map { keyValue in URLQueryItem(name: keyValue.0, value: keyValue.1) }
        components.queryItems = queryItems + components.queryItems!
        return components.url!
    }
}
