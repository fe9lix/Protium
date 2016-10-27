import UIKit

// Top-most Presentation Context.
// See: https://github.com/ReactiveKit/ReactiveGitter/blob/master/Common/WindowContext.swift
final class WindowContext: Context {
    let window: UIWindow
    let animated: Bool
    
    init(window: UIWindow, animated: Bool = true) {
        self.window = window
        self.animated = animated
    }
   
    // Attaches the UI as new Root View Controller to the Window if needed
    // and animates transition if UI replaces an existing Root View Controller.
    func present(_ ui: UIViewController) {
        if window.rootViewController == nil || !animated {
            window.rootViewController = ui
        } else {
            let screenshot = window.rootViewController!.view.snapshotView(afterScreenUpdates: false) ?? UIView()
            window.rootViewController = ui
            
            ui.view.addSubview(screenshot)
            
            UIView.animate(withDuration: 0.125, animations: {
                screenshot.alpha = 0
            }) { _ in
                screenshot.removeFromSuperview()
            }
        }
    }
}
