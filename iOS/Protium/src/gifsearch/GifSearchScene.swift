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
           
            // Subscribe to event when cell is selected and present new Scene for details screen.
            interactor.cellSelected.drive(onNext: { gifPM in
                GifDetailsScene(context: self.context, gateway: self.gateway, gif: Observable.just(gifPM)).presentInContext()
            }).addDisposableTo(ui.disposeBag)
           
            // For demo purposes only. Demonstrates how a custom event from a cell could be handled here.
            interactor.cellImageTapped.drive(onNext: { gifPM in
                log(gifPM)
            }).addDisposableTo(ui.disposeBag)
            
            return interactor
        }
    }
}
