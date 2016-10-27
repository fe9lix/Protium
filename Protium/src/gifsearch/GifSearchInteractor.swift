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
    let cellImageTapped: Driver<GifPM>
    
    // Private
    private let gateway: GifGate
    private let actions: GifSearchUI.Actions
    
    init(gateway: GifGate, actions: GifSearchUI.Actions) {
        self.gateway = gateway
        self.actions = actions
        
        cellSelected = actions.cellSelected
        cellImageTapped = actions.cellImageTapped
    }
    
    // Construction of Drivers/Observables is extracted into separate methods
    // so that lazy properties and intializers are kept clean.
    
    private func gifsDriver(actions: GifSearchUI.Actions) -> Driver<ListPM<GifPM>> {
        return actions.search.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance) // Throttle calls when search string changes quickly.
            .distinctUntilChanged() // Filter consecutive duplicates.
            .flatMapLatest { query -> Observable<GifList> in // Perform networking call via Gateway. If the search query is empty, return trending gifs.
                if query.isEmpty { return self.gateway.fetchTrendingGifs(limit: GifSearchInteractor.perPageLimit) }
                return self.searchGifs(loaded: [], query: query, nextPage: actions.loadNextPage)
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background)) // Perform conversion to Presentation Models on background queue.
            .map { ListPM(items: $0.items.map(GifPM.init), hasMore: $0.items.count < $0.totalCount) } // Map Gif Model to Presentation Model.
            .asDriver(onErrorJustReturn: ListPM<GifPM>.empty())
    }
    
    private func searchGifs(loaded: [Gif], query: String, nextPage: Observable<Void>) -> Observable<GifList> {
        return gateway.searchGifs(query: query, page: (offset: max(0, loaded.count - 1), limit: GifSearchInteractor.perPageLimit))
            .flatMap { gifList -> Observable<GifList> in
                var loadedList = gifList
                loadedList.items = loaded + gifList.items
               
                // No further items available, so just return all currently loaded items.
                if loadedList.items.count >= loadedList.totalCount {
                    return Observable.just(loadedList)
                }
               
                // With concat, all previous Observables have to be completed, 
                // i.e. when the first completes, the second is subscribed to and so on.
                // The second Observable in the list "blocks" until the nextPage Observable is triggered.
                return Observable.concat([
                    Observable.just(loadedList),
                    Observable.never().takeUntil(nextPage), // Do not emit items and do not terminate until nextPage emits an item.
                    self.searchGifs(loaded: loadedList.items, query: query, nextPage: nextPage)
                    ])
        }
    }
    
    // Derive loading state from Observables:
    // List is loading when loadNextPage has emitted value and ist has more items to load.
    private func loading() -> Driver<Bool> {
        let loadingStarted = actions.loadNextPage.asObservable().map({ _ in true })
        let loadingFinished = gifList.asObservable().map({ _ in false })
        let isLoading = Observable.of(loadingStarted, loadingFinished).merge()
        
        return Observable.combineLatest(isLoading, gifList.asObservable()) { $0 && $1.hasMore }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }
}
