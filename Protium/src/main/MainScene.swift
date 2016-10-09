import UIKit

final class MainScene {
    private let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    func presentInContext() {
        GifSearchScene(
            context: NavigationControllerContext(parent: context),
            gateway: GifGateway()).presentInContext()
    }
}
