import UIKit
import Kingfisher
import RxSwift

final class GifCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var model: GifPM! {
        didSet {
            // Load/cache/animate image via Kingfisher library.
            imageView.kf.setImage(with: model.imageURL, options: [.transition(.fade(0.2))])
        }
    }
    var imageTapped: ((GifPM) -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
       
        // For demo purposes only.
        imageTapped?(model)
    }
}
