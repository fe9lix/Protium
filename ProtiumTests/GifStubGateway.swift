import Foundation
import RxSwift
@testable import Protium

// Return hard-coded data for early development and testing purposes.
class GifStubGateway: GifGate {
    func searchGifs(query: String, page: GifPage) -> Observable<GifList> {
        let gifs = (page.offset..<(page.offset + page.limit)).map({ Gif(id: String($0)) })
        return Observable.just((items: gifs, totalCount: 100))
    }
    
    func fetchTrendingGifs(limit: Int) -> Observable<GifList> {
        let gifs = (0..<limit).map({ Gif(id: String($0)) })
        return Observable.just((items: gifs, totalCount: 100))
    }
}
