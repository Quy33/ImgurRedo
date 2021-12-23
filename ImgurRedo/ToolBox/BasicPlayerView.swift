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
//    override class var layerClass: AnyClass { AVPlayerLayer.self }
//    private var playerLayer: AVPlayerLayer? { self.layer as? AVPlayerLayer }
//
//    var player: AVQueuePlayer? {
//        get { playerLayer?.player as? AVQueuePlayer }
//        set { playerLayer?.player = newValue }
//    }
//
//    private var playerItem: AVPlayerItem?
//    private var playerLooper: AVPlayerLooper?
//    var url: URL?
//    var videoSize: CGSize? {
//        guard let link = url else { return nil }
//        guard let track = AVURLAsset(url: link).tracks(withMediaType: AVMediaType.video).first else {
//            return nil
//        }
//        let size = track.naturalSize.applying(track.preferredTransform)
//        return CGSize(width: abs(size.width), height: abs(size.height))
//    }
//
//    func setupPlayer(_ link: URL) {
//        url = link
//        let item = AVPlayerItem(url: link)
//        let queuePlayer = AVQueuePlayer(url: link)
//        queuePlayer.isMuted = true
//        playerItem = item
//        player = queuePlayer
//        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
//    }
//
//    func play() {
//        guard player?.isPlaying == false else { return }
//        player?.play()
//    }
//    func pause() {
//        guard player?.isPlaying == true else { return }
//        player?.pause()
//    }
//    func cleanup() {
//        pause()
//        player = nil
//        playerLooper = nil
//        playerItem = nil
//    }
//    deinit {
//        cleanup()
//    }
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    private var avPlayer: AVPlayer? {
        get{ playerLayer.player }
        set{ playerLayer.player = newValue }
    }
    private var playerItem: AVPlayerItem?
    private var url: URL?
    
    func prepareToPlay(url: URL, shouldPlayImmediately: Bool) {
        guard !(self.url == url && avPlayer != nil && avPlayer?.error == nil) else {
            if shouldPlayImmediately {
                play()
            }
            return
        }
        cleanup()
        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.playerItem = playerItem
        self.avPlayer = avPlayer
        self.url = url
        if shouldPlayImmediately {
            DispatchQueue.main.async {
                avPlayer.play()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidEndPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    func play() {
        guard avPlayer?.isPlaying == true else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.avPlayer?.play()
        }
    }
    func pause() {
        guard avPlayer?.isPlaying == false else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.avPlayer?.pause()
        }
    }
    @objc private func playerItemDidEndPlaying(_ notification: Notification) {
        guard (notification.object as? AVPlayerItem == playerItem) else {
            return
        }

        avPlayer?.seek(to: .zero)
        avPlayer?.play()
    }
    func cleanup() {
        pause()
        avPlayer = nil
        playerItem = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    deinit {
        cleanup()
    }
}
