import UIKit
import RxSwift
import SafariServices

final class GifDetailsScene {
    private let context: NavigationContext
    private let gateway: GifGate
    private let gif: Observable<GifPM>
    
    init(context: NavigationContext, gateway: GifGate, gif: Observable<GifPM>) {
        self.context = context
        self.gateway = gateway
        self.gif = gif
    }
    
    func presentInContext() {
        context.push(ui())
    }
    
    private func ui() -> UIViewController {
        return GifDetailsUI.create { ui in
            let interactor = GifDetailsInteractor(gateway: self.gateway, gif: self.gif, actions: ui.actions)
            
            interactor.urlToOpen.drive(onNext: { url in
                self.context.present(SFSafariViewController(url: url))
            }).addDisposableTo(ui.disposeBag)
            
            return interactor
        }
    }
}
