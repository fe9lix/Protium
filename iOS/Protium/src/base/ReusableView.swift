import UIKit

// See: https://realm.io/news/appbuilders-natasha-muraschev-practical-protocol-oriented-programming/

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
