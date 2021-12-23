//
//  PlayerView.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 14/12/2021.
//

import UIKit
import AVKit
import AVFoundation

class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    private func initialSetup() {
        if let layer = self.layer as? AVPlayerLayer {
            layer.videoGravity = .resizeAspectFill
        }
    }
    
    init() {
        super.init(frame: .zero)
        initialSetup()
    }
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        initialSetup()
    }
    
    private var playerItem: AVPlayerItem?
    private var urlAsset: AVURLAsset?
    private var url: URL?
    
    func prepareToPlay(withUrl url: URL, shouldPlayImmediately: Bool) {
        guard !(url == url && assetPlayer != nil) else {
            if shouldPlayImmediately {
                play()
            }
            return
        }
        
        cleanup()
        
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let urlAsset = AVURLAsset(url: url, options: options)
        self.urlAsset = urlAsset
        self.url = url
        
        let keys = ["tracks"]
        urlAsset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(urlAsset, shouldPlayImmediately: shouldPlayImmediately)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    private var assetPlayer: AVPlayer? {
        didSet {
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.assetPlayer
                }
            }
        }
    }
    
    private func startLoading(_ asset: AVURLAsset, shouldPlayImmediately: Bool) {
        var error: NSError?
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == .loaded {
            let item = AVPlayerItem(asset: asset)
            self.playerItem = item
            
            let player = AVPlayer(playerItem: item)
            self.assetPlayer = player
            if shouldPlayImmediately {
                DispatchQueue.main.async {
                    player.play()
                }
            }
        }
    }
    
    func play() {
        guard assetPlayer?.isPlaying == false else {
            return
        }
        self.assetPlayer?.play()
    }
    func pause() {
        guard assetPlayer?.isPlaying == true else {
            return
        }
        self.assetPlayer?.pause()
    }
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        guard notification.object as? AVPlayerItem == self.playerItem else {
            return
        }
        assetPlayer?.seek(to: .zero)
        assetPlayer?.play()
    }
    
    func cleanup() {
        pause()
        urlAsset?.cancelLoading()
        urlAsset = nil
        assetPlayer = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    deinit {
        cleanup()
    }
}
extension AVPlayer {
    var isPlaying: Bool {
        return (rate != 0 && error == nil)
    }
}
