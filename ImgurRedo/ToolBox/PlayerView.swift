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
    
    private var assetPlayer: AVPlayer? {
        didSet {
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    //.6
                    layer.player = self.assetPlayer
                }
            }
        }
    }
    private var playerItem: AVPlayerItem?
    private var urlAsset: AVURLAsset?
    
    func prepareToPlay(withUrl url: URL) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let urlAsset = AVURLAsset(url: url, options: options)
        self.urlAsset = urlAsset
        
        let keys = ["tracks"]
        urlAsset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(urlAsset)
        }
    }
    
    private func startLoading(_ asset: AVURLAsset) {
        var error: NSError?
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == .loaded {
            let item = AVPlayerItem(asset: asset)
            self.playerItem = item
            
            let player = AVPlayer(playerItem: item)
            self.assetPlayer = player
            player.play()
        }
    }
    
    func play() {
        guard assetPlayer?.isPlaying == false else {
            return
        }
        DispatchQueue.main.async {
            self.assetPlayer?.play()
        }
    }
    func pause() {
        guard assetPlayer?.isPlaying == true else {
            return
        }
        DispatchQueue.main.async {
            self.assetPlayer?.pause()
        }
    }
    
    func cleanup() {
        pause()
        urlAsset?.cancelLoading()
        urlAsset = nil
        assetPlayer = nil
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
