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
    
    deinit {
        log(self)
    }
   
    // Create the UI and Interactor for the details screen.
    // Register for updates when the user selects the "Open Giphy" button and present SafariViewController.
    private func createUI() -> UIViewController {
        return GifDetailsUI.create { ui in
            let interactor = GifDetailsInteractor(gateway: self.gateway, gif: self.gif, actions: ui.actions)
            
            interactor.urlToOpen.drive(onNext: { url in
                self.context.present(SFSafariViewController(url: url))
            }).addDisposableTo(ui.disposeBag)
            
            return interactor
        }
    }
    
    func presentInContext() {
        context.push(createUI())
    }
}
