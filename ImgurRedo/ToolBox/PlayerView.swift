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
    
    private var assetPlayer: AVPlayer? {
        didSet {
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.assetPlayer
                }
            }
        }
    }
    private var playerItem: AVPlayerItem?
    
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
    
    private var urlAsset: AVURLAsset?
    
    func prepareToPlay(withUrl url: URL) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let urlAsset = AVURLAsset(url: url, options: options)
        self.urlAsset = urlAsset
        
        let keys = ["tracks"]
        urlAsset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            guard let strongSelf = self else { return }
            
        }
    }
    
    
}
