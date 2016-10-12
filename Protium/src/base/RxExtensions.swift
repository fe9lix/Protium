import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    public var visible: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self.base) { view, visible in
            if visible {
                view.alpha = view.alpha >= 1.0 ? 0.0 : view.alpha
                view.isHidden = false
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = visible ? 1.0 : 0.0
            }) { finished in
                if finished {
                    view.isHidden = !visible
                }
            }
            }.asObserver()
    }
}
