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
    var videoSize: CGSize? {
        guard let link = url else { return nil }
        guard let track = AVURLAsset(url: link).tracks(withMediaType: AVMediaType.video).first else {
            return nil
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func setupPlayer(_ link: URL) {
        url = link
        let item = AVPlayerItem(url: link)
        let queuePlayer = AVQueuePlayer(url: link)
        queuePlayer.isMuted = true
        playerItem = item
        player = queuePlayer
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
    }
    
    func play() {
        guard player?.isPlaying == false else { return }
        player?.play()
    }
    func pause() {
        guard player?.isPlaying == true else { return }
        player?.pause()
    }
    func cleanup() {
        pause()
        player = nil
        playerLooper = nil
        playerItem = nil
    }
    deinit {
        cleanup()
    }
}
