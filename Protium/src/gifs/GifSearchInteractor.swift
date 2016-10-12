import Foundation
import RxSwift
import RxCocoa

final class GifSearchInteractor {
    static let perPageLimit = 25
    
    // UI Outputs
    lazy var gifList: Driver<ListPM<GifPM>> = self.gifsDriver(actions: self.actions)
    lazy var isLoading: Driver<Bool> = self.loading()
    
    // Scene Outputs
    let cellSelected: Driver<GifPM>
    
    // Private
    private let gateway: GifGate
    private let actions: GifSearchUI.Actions
    
    init(gateway: GifGate, actions: GifSearchUI.Actions) {
        self.gateway = gateway
        self.actions = actions
        
        cellSelected = actions.cellSelected
    }
    
    private func gifsDriver(actions: GifSearchUI.Actions) -> Driver<ListPM<GifPM>> {
        return actions.search.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<GifList> in
                if query.isEmpty { return self.gateway.fetchTrendingGifs(limit: GifSearchInteractor.perPageLimit) }
                return self.searchGifs(loaded: [], query: query, nextPage: actions.loadNextPage)
            }
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .background))
            .map { ListPM(items: $0.items.map(GifPM.init), hasMore: $0.items.count < $0.totalCount) }
            .asDriver(onErrorJustReturn: ListPM<GifPM>.empty())
    }
    
    private func searchGifs(loaded: [Gif], query: String, nextPage: Observable<Void>) -> Observable<GifList> {
        return gateway.searchGifs(query: query, page: (offset: max(0, loaded.count - 1), limit: GifSearchInteractor.perPageLimit))
            .flatMap { gifList -> Observable<GifList> in
                var loadedList = gifList
                loadedList.items = loaded + gifList.items
                
                if loadedList.items.count >= loadedList.totalCount {
                    return Observable.just(loadedList)
                }
                
                return Observable.concat([
                    Observable.just(loadedList),
                    Observable.never().takeUntil(nextPage),
                    self.searchGifs(loaded: loadedList.items, query: query, nextPage: nextPage)
                    ])
        }
    }
    
    private func loading() -> Driver<Bool> {
        let loadingStarted = actions.loadNextPage.asObservable().map({ _ in true })
        let loadingFinished = gifList.asObservable().map({ _ in false })
        let isLoading = Observable.of(loadingStarted, loadingFinished).merge()
        
        return Observable.combineLatest(isLoading, gifList.asObservable()) { $0 && $1.hasMore }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }
}
