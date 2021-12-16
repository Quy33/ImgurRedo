//
//  BasicPlayerView.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/12/2021.
//

import UIKit
import AVKit
import AVFoundation

class BasicPlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer? { self.layer as? AVPlayerLayer }
    
    var player: AVQueuePlayer? {
        get { playerLayer?.player as? AVQueuePlayer }
        set { playerLayer?.player = newValue }
    }
    
    private var playerItem: AVPlayerItem?
    private var playerLooper: AVPlayerLooper?
    var url: URL?
    
    func setupPlayer(_ link: URL) {
        url = link
        let item = AVPlayerItem(url: link)
        let queuePlayer = AVQueuePlayer(url: link)
        queuePlayer.isMuted = true
        playerItem = item
        player = queuePlayer
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
    }
}
