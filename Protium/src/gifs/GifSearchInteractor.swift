import Foundation
import RxSwift
import RxCocoa

final class GifSearchInteractor {
    static let perPageLimit = 25
    
    // UI Outputs
    lazy var gifs: Driver<[GifPM]> = self.gifsDriver(actions: self.actions)
    
    // Scene Outputs
    let cellSelected: ControlEvent<GifPM>
    
    // Private
    private let gateway: GifGate
    private let actions: GifSearchUI.Actions
    
    init(gateway: GifGate, actions: GifSearchUI.Actions) {
        self.gateway = gateway
        self.actions = actions
        
        cellSelected = actions.cellSelected
    }
    
    private func gifsDriver(actions: GifSearchUI.Actions) -> Driver<[GifPM]> {
        return actions.search.asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { query -> Driver<[GifPM]> in
                if query.isEmpty { return self.toPresentation(gifs: self.gateway.fetchTrending(limit: GifSearchInteractor.perPageLimit)) }
                return self.toPresentation(gifs: self.searchGifs(loaded: [], query: query, nextPage: actions.loadNextPage))
            }
    }
    
    private func searchGifs(loaded: [Gif], query: String, nextPage: Observable<Void>) -> Observable<[Gif]> {
        return gateway.searchGifs(query: query, page: (offset: max(0, loaded.count - 1), limit: GifSearchInteractor.perPageLimit))
            .flatMap { gifs -> Observable<[Gif]> in
                if gifs.isEmpty {
                    return Observable.just(loaded)
                }
                
                let loadedGifs = loaded + gifs
                
                return Observable.concat([
                    Observable.just(loadedGifs),
                    Observable.never().takeUntil(nextPage),
                    self.searchGifs(loaded: loadedGifs, query: query, nextPage: nextPage)
                    ])
        }
    }
    
    private func toPresentation(gifs: Observable<[Gif]>) -> Driver<[GifPM]> {
        return gifs.retry()
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .background))
            .map { $0.map(GifPM.init) }
            .asDriver(onErrorJustReturn: [])
    }
}
