import UIKit

//See: https://realm.io/news/appbuilders-natasha-muraschev-practical-protocol-oriented-programming/

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let nib = UINib(nibName: T.NibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
}

extension UICollectionViewCell: ReusableView, NibLoadableView {}

// Convenience method that indicates if the user has scrolled to the end of the list minus some padding.
// See: https://github.com/ReactiveX/RxSwift/blob/master/RxExample/RxExample/Examples/GitHubSearchRepositories/GitHubSearchRepositoriesViewController.swift
extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}
