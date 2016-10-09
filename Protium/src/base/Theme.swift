import UIKit

final class Theme {
    // MARK: - Appearance
    class func apply(to window: UIWindow) {
        window.tintColor = UIColor.white
        
        applyNavigationBarAppearance()
    }
    
    private class func applyNavigationBarAppearance() {
        UINavigationBar.appearance().barStyle = .blackTranslucent
        UINavigationBar.appearance().tintColor = UIColor.white
    }
}
