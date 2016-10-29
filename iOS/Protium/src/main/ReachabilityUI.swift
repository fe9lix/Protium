import UIKit

final class ReachabilityUI: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Lifecycle
    
    class func create() -> ReachabilityUI {
       return UIStoryboard(name: "Reachability", bundle: Bundle(for: ReachabilityUI.self)).instantiateInitialViewController() as! ReachabilityUI
    }
    
    deinit {
        log(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.text = "Reachability.Unreachable".localized
    }
}
