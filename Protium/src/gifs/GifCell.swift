import UIKit
import Kingfisher

final class GifCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var model: GifPM! {
        didSet {
            imageView.kf.setImage(with: model.imageURL, options: [.transition(.fade(0.2))])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
    }
}
