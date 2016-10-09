import UIKit
import RxSwift
import RxCocoa

final class GifSearchUI: InteractableUI<GifSearchInteractor> {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    class func create(interactorFactory: @escaping (GifSearchUI) -> GifSearchInteractor) -> GifSearchUI {
        return create(
            storyboard: UIStoryboard(name: "GifSearch", bundle: Bundle(for: GifSearchUI.self)),
            interactorFactory: downcast(interactorFactory)
            ) as! GifSearchUI
    }
    
    override func viewDidLoad() {
        title = "GifSearch.Title".localized
        searchTextField.becomeFirstResponder()
        super.viewDidLoad()
    }
    
    // MARK: - Bindings
    override func bindInteractor(interactor: GifSearchInteractor) {
        collectionView.register(GifCell.self)
        
        // Update presentation models for cells.
        interactor.gifs
            .drive(collectionView.rx.items(cellIdentifier: GifCell.reuseIdentifier, cellType: GifCell.self)) { index, model, cell in
                cell.model = model
            }
            .addDisposableTo(disposeBag)
        
        // Dismiss Keyboard when list is scrolled.
        collectionView.rx.contentOffset
            .subscribe { _ in
                if self.searchTextField.isFirstResponder {
                    _ = self.searchTextField.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewFlowLayout.itemSize = CGSize(width: (collectionView.bounds.width * 0.5).rounded(.down), height: 100.0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewFlowLayout.invalidateLayout()
    }
}

extension GifSearchUI {
    struct Actions {
        let search: ControlProperty<String>
        let loadNextPage: Observable<Void>
        let cellSelected: ControlEvent<GifPM>
    }
    
    var actions: Actions {
        return Actions(
            search: searchTextField.rx.text,
            loadNextPage: collectionView.rx.contentOffset
                .flatMap { _ in self.collectionView.isNearBottomEdge(edgeOffset: 20.0) ? Observable.just(()) : Observable.empty() },
            cellSelected: collectionView.rx.modelSelected(GifPM.self)
        )
    }
}
