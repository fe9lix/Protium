import UIKit

// See: https://realm.io/news/appbuilders-natasha-muraschev-practical-protocol-oriented-programming/
protocol NibLoadableView: class {}

extension NibLoadableView where Self: UIView {
    static var NibName: String {
        return String(describing: self)
    }
}
