import SpriteKit
import AVFoundation

public class VideoNode: SKVideoNode {
    
    let player: AVPlayer
    
    required init?(coder decoder: NSCoder) { fatalError("Not available") }
    
    public init(url: URL, loops: Bool) {
        player = AVPlayer(url: url)
        super.init(avPlayer: player)
        
        if loops {
            player.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(self, selector: #selector(rewind), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    @objc func rewind() {
        player.seek(to: .zero)
    }
    
}
