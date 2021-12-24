//
//  BasicPlayerView.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/12/2021.
//

import UIKit
import AVKit
import AVFoundation

class BasicPlayerView: UIImageView {
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
    
    private var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
        return view
    }()
    
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
            self.contentMode = .center
        }
    }
    private func setupSpinner() {
        self.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
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
        setupSpinner()
        spinner.startAnimating()
        asset.loadValuesAsynchronously(forKeys: key) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(asset: asset, shouldPlayImmediately: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidEndPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    private func startLoading(asset: AVURLAsset, shouldPlayImmediately: Bool) {
        var error: NSError?
        let status = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == .loaded {
            let item = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: item)
            playerItem = item
            avPlayer = player
            if shouldPlayImmediately {
                player.play()
            }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.spinner.stopAnimating()
                strongSelf.spinner.removeFromSuperview()
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
        url = nil
        urlAsset?.cancelLoading()
        urlAsset = nil
        playerItem = nil
        avPlayer = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    deinit {
        cleanup()
    }
}
extension AVPlayer {
    var isPlaying: Bool {
        return (self.rate != 0 && self.error == nil)
    }
}
