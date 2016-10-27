import UIKit

// Presentation Context for modal presentation.
// See: https://github.com/ReactiveKit/ReactiveGitter/blob/master/Common/ModalContext.swift
public class ModalContext: Context {
    let presenter: UIViewController
    let animated: Bool
    
    public init(presenter: UIViewController, animated: Bool) {
        self.presenter = presenter
        self.animated = animated
    }
    
    public func present(_ ui: UIViewController) {
        presenter.present(ui, animated: true, completion: nil)
    }
}
