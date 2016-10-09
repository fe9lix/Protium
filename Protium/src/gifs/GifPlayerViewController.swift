import AVFoundation
import AVKit

final class GifPlayerViewController: AVPlayerViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func play(url: URL) {
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        self.player = player
        player.play()
    }
    
    @objc private func playerItemDidPlayToEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero)
        }
    }
}
