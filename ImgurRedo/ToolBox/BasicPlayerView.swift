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
    var playerLayer: AVPlayerLayer?
    
    private var avPlayer: AVPlayer? {
        get{ playerLayer?.player }
        set{ playerLayer?.player = newValue }
    }
    private var url: URL?
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var assetExporter: AVAssetExportSession?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        if let layer = layer as? AVPlayerLayer {
            layer.videoGravity = .resizeAspectFill
            playerLayer = layer
        }
    }
    
    func prepareToPlay(url: URL, shouldPlayImmediately: Bool) {
        guard !(self.url == url && avPlayer != nil && avPlayer?.error == nil) else {
            if shouldPlayImmediately {
                play()
            }
            return
        }
        cleanup()
        
        self.url = url
        let option = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        let asset = AVURLAsset(url: url, options: option)
        let key = ["tracks"]
        urlAsset = asset
        asset.loadValuesAsynchronously(forKeys: key) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(asset: asset, shouldPlayImmediately: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidEndPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    private func startLoading(asset: AVURLAsset, shouldPlayImmediately: Bool) {
        var error: NSError?
        if asset.statusOfValue(forKey: "tracks", error: &error) == .loaded {
            let item = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: item)
            playerItem = item
            avPlayer = player
            if shouldPlayImmediately {
                player.play()
            }
        }
    }
    func play() {
        guard avPlayer?.isPlaying == true else {
            return
        }
        avPlayer?.play()
    }
    func pause() {
        guard avPlayer?.isPlaying == false else {
            return
        }
        avPlayer?.pause()
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
