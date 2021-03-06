import UIKit
import RxSwift
import RxCocoa

final class GifDetailsUI: InteractableUI<GifDetailsInteractor> {
    @IBOutlet weak var copyEmbedLinkButton: UIButton!
    @IBOutlet weak var openGiphyButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    private var playerViewController: GifPlayerViewController?
    
    // MARK: - Lifecycle
    
    class func create(interactorFactory: @escaping (GifDetailsUI) -> GifDetailsInteractor) -> GifDetailsUI {
        return create(
            storyboard: UIStoryboard(name: "GifDetails", bundle: Bundle(for: GifDetailsUI.self)),
            interactorFactory: downcast(interactorFactory)
            ) as! GifDetailsUI
    }
    
    deinit {
        log(self)
    }
   
    // The Gif Player is shown using a container view in the storyboard and an embed segue.
    // Use the "prepare" call to store a reference to GifPlayerViewController that
    // starts playback when the Gif-Observable triggers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        
        if case .gifPlayer? = Segue(rawValue: identifier) {
            playerViewController = segue.destination as? GifPlayerViewController
        }
    }
    
    override func viewDidLoad() {
        copyEmbedLinkButton.setTitle("GifDetails.CopyEmbedLink".localized, for: .normal)
        openGiphyButton.setTitle("GifDetails.OpenGiphy".localized, for: .normal)
        
        super.viewDidLoad()
    }
    
    // MARK: - Bindings
    
    override func bindInteractor(interactor: GifDetailsInteractor) {
        interactor.gif.drive(onNext: { gif in
            self.playVideo(url: gif.videoURL)
        }).addDisposableTo(disposeBag)
        
        interactor.gif
            .map { $0.embedURL == nil }
            .drive(self.copyEmbedLinkButton.rx.isHidden)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Video Playback
    
    private func playVideo(url: URL?) {
        guard let url = url, let playerViewController = playerViewController else { return }
        playerViewController.play(url: url)
    }
}

extension GifDetailsUI {
    struct Actions {
        let copyEmbedLink: Driver<Void>
        let openGiphy: Driver<Void>
    }
    
    var actions: Actions {
        return Actions(
            copyEmbedLink: copyEmbedLinkButton.rx.tap.asDriver(),
            openGiphy: openGiphyButton.rx.tap.asDriver()
        )
    }
}

extension GifDetailsUI {
    enum Segue: String {
        case gifPlayer
    }
}
