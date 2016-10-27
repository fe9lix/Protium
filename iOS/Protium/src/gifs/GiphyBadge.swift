import UIKit
import Kingfisher

// Displays animated gif as loading indicator.
final class GiphyBadge: AnimatedImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        kf.setImage(with: Bundle(for: GiphyBadge.self).url(forResource: "giphyBadge", withExtension: "gif"))
    }
}
