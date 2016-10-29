import UIKit
import RxSwift
import RxCocoa

final class GifSearchUI: InteractableUI<GifSearchInteractor> {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var loadingView: GiphyBadge!
   
    let disposeBag = DisposeBag()
    
    fileprivate let cellImageTapped = PublishSubject<GifPM>()
    
    // MARK: - Lifecycle
    
    class func create(interactorFactory: @escaping (GifSearchUI) -> GifSearchInteractor) -> GifSearchUI {
        return create(
            storyboard: UIStoryboard(name: "GifSearch", bundle: Bundle(for: GifSearchUI.self)),
            interactorFactory: downcast(interactorFactory)
            ) as! GifSearchUI
    }
    
    override func viewDidLoad() {
        title = "GifSearch.Title".localized
        super.viewDidLoad()
    }
    
    // MARK: - Bindings
    
    override func bindInteractor(interactor: GifSearchInteractor) {
        collectionView.register(GifCell.self)
        
        // Update presentation models for cells.
        interactor.gifList
            .map { $0.value?.items ?? [] }
            .drive(collectionView.rx.items(cellIdentifier: GifCell.reuseIdentifier, cellType: GifCell.self)) { index, model, cell in
                cell.model = model
                // Closure registered for demo purposes only:
                // Shows how an event occuring in a nested view component can be bubbled up.
                // If the cell support multiple different events, it might make more sense to
                // use the delegation pattern here instead of closures.
                cell.imageTapped = { [unowned self] gifPM in
                    self.cellImageTapped.onNext(gifPM)
                }
            }
            .addDisposableTo(disposeBag)
       
        // Error handling.
        interactor.gifList
            .filter { $0.isError }
            .drive(onNext: { result in
                log(result.error) // Errors could be displayed here. In this example, just log.
            })
            .addDisposableTo(disposeBag)
        
        // Dismiss Keyboard when list is scrolled.
        collectionView.rx.contentOffset
            .subscribe { _ in
                if self.searchTextField.isFirstResponder {
                    _ = self.searchTextField.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)
        
        // Toggle loading state: Increase bottom inset to make room for loading badge.
        interactor.isLoading
            .drive(onNext: { loading in
                self.collectionView.contentInset = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: loading ? 72 : 0,
                    right: 0
                )}
            )
            .addDisposableTo(disposeBag)
        
        interactor.isLoading
            .drive(self.loadingView.rx.visible)
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
    // Note that this Struct contains *reference* types as properties,
    // therefore copy-semantics are different than for pure value types.
    // The struct here should merely be regarded as convenience container for UI actions 
    // that are passed as "parameter object" to the Interactor.
    struct Actions {
        let search: Driver<String>
        let loadNextPage: Observable<Void>
        let cellSelected: Driver<GifPM>
        var cellImageTapped: Driver<GifPM>
    }
   
    // Extensions only support computed properties. Since this struct is created each time it is accessed,
    // make sure to reference existing Rx streams here.
    var actions: Actions {
        return Actions(
            search: searchTextField.rx.text.orEmpty.asDriver(),
            loadNextPage: collectionView.rx.contentOffset
                .flatMap { _ in self.collectionView.isNearBottomEdge(edgeOffset: 20.0) ? Observable.just(()) : Observable.empty() },
            cellSelected: collectionView.rx.modelSelected(GifPM.self).asDriver(),
            cellImageTapped: cellImageTapped.asDriver(onErrorJustReturn: GifPM.empty())
        )
    }
}
