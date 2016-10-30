import Foundation
import RxSwift
import RxCocoa

// Results from Gateways are wrapped in a generic Result type after conversion to Presentation Models.
// This enables the UI to present meaningful errors to the user in case something went wrong.
typealias GifResult = Result<ListPM<GifPM>, GifSearchError>

// Error type representing all error cases in the "GifSearch" domain.
enum GifSearchError: Error {
    case general // For this demo, only one generic error case is supported.
}

final class GifSearchInteractor {
    static let perPageLimit = 25
    
    // UI Outputs
    lazy var gifList: Driver<GifResult> = self.gifsDriver(actions: self.actions)
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
    
    private func gifsDriver(actions: GifSearchUI.Actions) -> Driver<GifResult> {
        return actions.search
            .throttle(0.3) // Throttle calls when search string changes quickly.
            .distinctUntilChanged() // Filter consecutive duplicates.
            .flatMapLatest { query -> Driver<GifResult> in // Perform networking call via Gateway. If the search query is empty, return trending gifs.
                let gifList: Observable<GifList>
                if query.isEmpty {
                    gifList = self.gateway.fetchTrendingGifs(limit: GifSearchInteractor.perPageLimit)
                } else {
                    gifList = self.searchGifs(loaded: [], query: query, nextPage: actions.loadNextPage)
                }
                
                return gifList.observeOn(ConcurrentDispatchQueueScheduler(qos: .background)) // Perform conversion to Presentation Models on background queue.
                    .map { .success(ListPM(items: $0.items.map(GifPM.init), hasMore: $0.items.count < $0.totalCount)) } // Map Gif Model to Presentation Model.
                    .asDriver { error in // Error occuring in GifGateway could be converted to more meaningful error for the user here.
                        log(error)
                        return Driver.just(.failure(.general))
                    }
            }
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
    // List is loading when loadNextPage has emitted value and it has more items to load.
    private func loading() -> Driver<Bool> {
        let loadingStarted = actions.loadNextPage.asObservable().map({ _ in true })
        let loadingFinished = gifList.asObservable().map({ _ in false })
        let isLoading = Observable.of(loadingStarted, loadingFinished).merge()
        
        return Observable.combineLatest(isLoading, gifList.asObservable()) { $0 && ($1.value?.hasMore ?? false) }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }
}
