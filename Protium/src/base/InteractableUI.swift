import UIKit

class InteractableUI<Interactor>: UIViewController {
    var interactor: Interactor!
    
    private var interactorFactory: ((InteractableUI) -> Interactor)!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, interactorFactory: @escaping (InteractableUI) -> Interactor) {
        self.interactorFactory = interactorFactory
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func create(storyboard: UIStoryboard, interactorFactory: @escaping (InteractableUI) -> Interactor) -> InteractableUI {
        let viewController = storyboard.instantiateInitialViewController() as! InteractableUI
        viewController.interactorFactory = interactorFactory
        return viewController
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor = interactorFactory(self)
        interactorFactory = nil
        bindInteractor(interactor: interactor)
    }
    
    func bindInteractor(interactor: Interactor) {}
    
    class func downcast<T, U, D>(_ closure: @escaping (T) -> D) -> ((U) -> D) {
        return { a in closure(a as! T) }
    }
}
