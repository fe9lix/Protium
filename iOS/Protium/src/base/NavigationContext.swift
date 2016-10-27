import UIKit

protocol NavigationContext: Context {
    func push(_ ui: UIViewController)
    func pop()
}

// Presentation Context for stack-like push/pop navigation.
// Internally uses UINavigationController.
// See: https://github.com/ReactiveKit/ReactiveGitter/blob/master/Common/NavigationContext.swift
final class NavigationControllerContext: NavigationContext {
    let parent: Context
    let animated: Bool
    weak var navigationController: UINavigationController!
    
    init(parent: Context, animated: Bool = true) {
        self.parent = parent
        self.animated = animated
    }
    
    func push(_ ui: UIViewController) {
        if let navigationController = navigationController {
            navigationController.pushViewController(ui, animated: animated)
        } else {
            let navigationController = UINavigationController(rootViewController: ui)
            parent.present(navigationController)
            self.navigationController = navigationController
        }
    }
    
    func pop() {
        navigationController.popViewController(animated: animated)
    }
    
    func present(_ ui: UIViewController) {
        if let navigationController = navigationController {
            navigationController.present(ui, animated: animated, completion: nil)
        } else {
            parent.present(ui)
        }
    }
}
