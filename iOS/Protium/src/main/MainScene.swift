import UIKit
import RxSwift

final class MainScene {
    private let context: Context
    private let reachabilityService: ReachabilityService
    private let disposeBag = DisposeBag()
    
    private var gifSearchScene: GifSearchScene?
    private var reachabilityUI: ReachabilityUI?
    
    init(context: Context) {
        self.context = context
        self.reachabilityService = try! DefaultReachabilityService() // Crashy crashy if Reachability can't be initialized.
    }
    
    // The Main Scene presents the initial Scene for searching Gifs and
    // provides the dependencies: A NavigationContext (list/detail screen) and the relevant Gateway.
    // Internally GifSearchScene then constructs the Interactor and UserInterface.
    func presentInContext() {
        gifSearchScene = GifSearchScene(
            context: NavigationControllerContext(parent: context),
            gateway: GifGateway(reachabilityService: reachabilityService))
        gifSearchScene?.presentInContext()
        
        handleReachability()
    }
    
    // Handle Reachability: Present custom UI on top when network connection is lost.
    // This *could* be moved into a separate Scene as well. In this example, however,
    // the ReachabilityUI is simply presented via GifSearchScene's context.
    private func handleReachability() {
        reachabilityService.reachability.asDriver(onErrorJustReturn: .unreachable).drive(onNext: { status in
            log(status)
            switch status {
            case .reachable:
                self.reachabilityUI?.dismiss(animated: true) {
                    self.reachabilityUI = nil
                }
            case .unreachable:
                self.reachabilityUI = ReachabilityUI.create()
                self.reachabilityUI?.modalTransitionStyle = .crossDissolve
                self.gifSearchScene?.present(self.reachabilityUI!)
            }})
            .addDisposableTo(disposeBag)
    }
}
