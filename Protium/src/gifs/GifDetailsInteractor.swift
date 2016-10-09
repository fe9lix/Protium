import Foundation
import RxSwift
import RxCocoa

final class GifDetailsInteractor {
    // UI Outputs
    let gif: Driver<GifPM>
    
    // Scene Outputs
    let urlToOpen: Driver<URL>
    
    // Private
    private let disposeBag = DisposeBag()
    
    init(gateway: GifGate, gif: Observable<GifPM>, actions: GifDetailsUI.Actions) {
        self.gif = gif.asDriver(onErrorJustReturn: GifPM.empty())
        
        Observable.combineLatest(gif, actions.copyEmbedLink.asObservable()) { (gif, _) in gif.embedURL }
            .subscribe(onNext: { url in UIPasteboard.general.url = url })
            .addDisposableTo(disposeBag)
        
        urlToOpen = Observable.combineLatest(gif, actions.openGiphy.asObservable()) { (gif, _) in gif.url! }
            .asDriver(onErrorJustReturn: URL(string: "https://www.giphy.com")!)
    }
}
