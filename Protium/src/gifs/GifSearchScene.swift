import UIKit
import RxSwift

final class GifSearchScene {
    private let context: NavigationContext
    private let gateway: GifGate
    
    init(context: NavigationContext, gateway: GifGate) {
        self.context = context
        self.gateway = gateway
    }
    
    func presentInContext() {
        context.push(ui())
    }
    
    private func ui() -> UIViewController {
        return GifSearchUI.create { ui in
            let interactor = GifSearchInteractor(gateway: self.gateway, actions: ui.actions)
            
            interactor.cellSelected.subscribe(onNext: { gifPM in
                GifDetailsScene(context: self.context, gateway: self.gateway, gif: Observable.just(gifPM)).presentInContext()
            }).addDisposableTo(ui.disposeBag)
            
            return interactor
        }
    }
}
