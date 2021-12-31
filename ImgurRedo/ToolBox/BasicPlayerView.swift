//
//  BasicPlayerView.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/12/2021.
//

import UIKit
import AVKit
import AVFoundation

@objc protocol BasicPlayerViewDelegate {
    func presentAVPlayerVC(url: URL,playFunction:@escaping ((Bool)->Void))
    @objc optional func pauseAllCurrentPlayer()
}

class BasicPlayerView: UIImageView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    var playerLayer: AVPlayerLayer?
    var delegate: BasicPlayerViewDelegate?
    
    private var avPlayer: AVPlayer? {
        get{ playerLayer?.player }
        set{ playerLayer?.player = newValue }
    }
    var showControls = true
    
    private var url: URL?
    private var urlOnDisk: URL?
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var assetExporter: AVAssetExportSession?
    private var documentDir = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
    ).last!
    
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var showViewBtn = UIButton(type: .system)
    private var playPauseBtn = UIButton(type: .system)
    private var muteBtn = UIButton(type: .system)
    
//MARK: Init
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
            
            self.contentMode = .scaleAspectFit
            self.isUserInteractionEnabled = true
            
            setupMuteBtn()
            if showControls {
                setupShowViewBtn()
                setupPlayPauseBtn()
            }
        }
    }
//MARK: Setup Player
    func prepareToPlay(url: URL, shouldPlayImmediately: Bool) {
        let fileUrl = documentDir.appendingPathComponent(url.lastPathComponent)
        let fileExist = FileManager.default.fileExists(atPath: fileUrl.path)
        
        let firstCondition = !(self.url == url
                               && avPlayer != nil
                               && avPlayer?.error == nil)
        let secondCondition = !(urlOnDisk == fileUrl
                                && assetExporter != nil
                                && assetExporter?.error == nil)

        guard firstCondition || secondCondition else {
            if shouldPlayImmediately {
                play()
            }
            return
        }
        cleanup()
        
        let videoUrl = fileExist ? fileUrl : url
        let option = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        let asset = AVURLAsset(url: videoUrl, options: option)
        let key = ["tracks"]
        
        self.url = url
        urlOnDisk = fileExist ? fileUrl : nil
        urlAsset = asset
        setupSpinner()
        spinner.startAnimating()
        asset.loadValuesAsynchronously(forKeys: key) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(asset: asset, shouldPlayImmediately: shouldPlayImmediately)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidEndPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    private func startLoading(asset: AVURLAsset, shouldPlayImmediately: Bool) {
        var error: NSError?
        let status = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == .loaded {
            let item = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: item)
            player.isMuted = true
            
            playerItem = item
            avPlayer = player
            avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.spinner.stopAnimating()
                
                strongSelf.muteBtn.isHidden = asset.tracks(withMediaType: .audio).isEmpty
                if strongSelf.showControls {
                    strongSelf.showViewBtn.isHidden = false
                    strongSelf.playPauseBtn.isHidden = false
                }
                if shouldPlayImmediately {
                    strongSelf.play()
                }
            }
            exportVideo(asset: asset)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = avPlayer else { return }
        
        if object as AnyObject? === avPlayer {
            if keyPath == "timeControlStatus",
               let change = change,
               let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int,
               let newValue = change[NSKeyValueChangeKey.newKey] as? Int
            {
                
                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                
                if newStatus != oldStatus {
                    if newStatus == .playing || newStatus == .paused {
                        spinner.stopAnimating()
                    } else {
                        spinner.startAnimating()
                    }
                    updatePlayBtn()
                }
            }
        }
    }
//MARK: Player Function
    func play(now: Bool = false) {
        guard let avPlayer = avPlayer, avPlayer.timeControlStatus == .paused else {
            return
        }
        DispatchQueue.main.async {
            if now {
                avPlayer.playImmediately(atRate: 1.0)
            } else {
                avPlayer.play()
            }
        }
    }
    func pause() {
        guard let avPlayer = avPlayer,
        (avPlayer.timeControlStatus == .playing ||
         avPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate) else {
            return
        }
        DispatchQueue.main.async {
            avPlayer.pause()
        }
    }
    func toggleMute(isMuted: Bool) {
        guard let avPlayer = avPlayer else { return }
        
        let muteBtnImg = isMuted ? Support.muted : Support.unMute
        avPlayer.isMuted = isMuted
        muteBtn.setImage(muteBtnImg, for: .normal)
    }
    func updatePlayBtn() {
        guard let status = avPlayer?.timeControlStatus else { return }
        
        var newImage: UIImage?
        
        switch status {
        case .paused:
            newImage = Support.play
        case .waitingToPlayAtSpecifiedRate:
            newImage = Support.play
        case .playing:
            newImage = Support.pause
        @unknown default:
            break
        }
        playPauseBtn.setImage(
            newImage,
            for: .normal
        )
    }
//MARK: Looping Player & Exporting Video
    @objc private func playerItemDidEndPlaying(_ notification: Notification) {
        guard (notification.object as? AVPlayerItem == playerItem) else { return }
        avPlayer?.seek(to: .zero)
        avPlayer?.play()
    }
    
    private func exportVideo(asset: AVURLAsset) {
        let outputUrl = self.documentDir.appendingPathComponent(asset.url.lastPathComponent)
        
        let firstCondition = (asset.isExportable && !FileManager.default.fileExists(atPath: outputUrl.path))
        let secondCondition = (assetExporter != nil && assetExporter?.error == nil)
        
        guard firstCondition && !secondCondition else {
            return
        }
        stopExporter()
        
        let invalidTrack = CMPersistentTrackID(kCMPersistentTrackID_Invalid)
        let composition = AVMutableComposition()
        let timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
        
        if let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: invalidTrack
        ), let sourceVideoTrack = asset.tracks(withMediaType: .video).first {
            do {
                try compositionVideoTrack.insertTimeRange(timeRange, of: sourceVideoTrack, at: .zero)
            } catch {
                print("Failed to compose video file")
                return
            }
        }
        
        if !asset.tracks(withMediaType: .audio).isEmpty {
            if let compositionalAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: invalidTrack
            ), let sourceAudioTrack = asset.tracks(withMediaType: .audio).first {
                do {
                    try compositionalAudioTrack.insertTimeRange(timeRange, of: sourceAudioTrack, at: .zero)
                } catch {
                    print("Failed to compose audio file")
                    return
                }
            }
        }
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality) else { return }
        
        exporter.outputURL = outputUrl
        exporter.outputFileType = .mp4
        assetExporter = exporter
        
        exporter.exportAsynchronously { [weak self] in
            guard let strongSelf = self else { return }
            if let error = exporter.error {
                print("Error Exporting: \(error)")
            } else {
                guard exporter.status == .completed else { return }
                print("Finished exporting")
                strongSelf.urlOnDisk = exporter.outputURL
            }
        }
    }
    func stopExporter() {
        assetExporter?.cancelExport()
        switch assetExporter?.status {
        case .failed, .cancelled:
            do {
                if let videoUrl = assetExporter?.outputURL {
                    guard FileManager.default.fileExists(atPath: videoUrl.path) else {
                        return
                    }
                    print("Deleting video not finish being exported")
                    try FileManager.default.removeItem(at: videoUrl)
                }
            } catch {
                print("Error removing unfinished video: \(error)")
            }
        default:
            break
        }
        assetExporter = nil
    }
//MARK: UI setup
    private func setupSpinner() {
        let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.frame = rect
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = Support.playerUITint
        spinner.backgroundColor = Support.playerUIColor
        spinner.clipsToBounds = true
        spinner.layer.cornerRadius = spinner.frame.height / 2
        spinner.hidesWhenStopped = true
        self.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spinner.widthAnchor.constraint(
                equalToConstant: spinner.frame.width),
            spinner.heightAnchor.constraint(
                equalToConstant: spinner.frame.height)
        ])
    }
    private func setupShowViewBtn() {
        showViewBtn.translatesAutoresizingMaskIntoConstraints = false
        showViewBtn.backgroundColor = .clear
        showViewBtn.isHidden = true
        
        showViewBtn.addTarget(self, action: #selector(showViewDidPressed(_:)), for: .touchUpInside)
        self.addSubview(showViewBtn)
        NSLayoutConstraint.activate([
            showViewBtn.topAnchor.constraint(
                equalTo: self.topAnchor),
            showViewBtn.bottomAnchor.constraint(
                equalTo: self.bottomAnchor),
            showViewBtn.leadingAnchor.constraint(
                equalTo: self.leadingAnchor),
            showViewBtn.trailingAnchor.constraint(
                equalTo: self.trailingAnchor)
        ])
    }
    private func setupPlayPauseBtn() {
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.backgroundColor = Support.playerUIColor
        playPauseBtn.tintColor = Support.playerUITint
        playPauseBtn.frame = Support.playerUIFrame
        playPauseBtn.clipsToBounds = true
        playPauseBtn.layer.cornerRadius = playPauseBtn.frame.height/3
        playPauseBtn.isHidden = true
        playPauseBtn.setImage(Support.play, for: .normal)
        
        playPauseBtn.addTarget(self, action: #selector(playPauseDidPressed(_:)), for: .touchUpInside)
        self.addSubview(playPauseBtn)
        NSLayoutConstraint.activate([
            playPauseBtn.leadingAnchor.constraint(
                equalTo: self.leadingAnchor, constant: 5
            ),
            playPauseBtn.bottomAnchor.constraint(
                equalTo: self.bottomAnchor, constant: -5
            ),
            playPauseBtn.widthAnchor.constraint(
                equalToConstant: playPauseBtn.frame.width),
            playPauseBtn.heightAnchor.constraint(
                equalToConstant: playPauseBtn.frame.height)
        ])
    }
    private func setupMuteBtn() {
        muteBtn.translatesAutoresizingMaskIntoConstraints = false
        muteBtn.backgroundColor = Support.playerUIColor
        muteBtn.tintColor = Support.playerUITint
        muteBtn.frame = Support.playerUIFrame
        muteBtn.clipsToBounds = true
        muteBtn.layer.cornerRadius = muteBtn.frame.height/2
        muteBtn.isHidden = true
        muteBtn.setImage(Support.muted, for: .normal)
        muteBtn.addTarget(self, action: #selector(muteBtnPressed(_:)), for: .touchUpInside)
        self.addSubview(muteBtn)
        NSLayoutConstraint.activate([
            muteBtn.trailingAnchor.constraint(
                equalTo: self.trailingAnchor, constant: -5
            ),
            muteBtn.topAnchor.constraint(
                equalTo: self.topAnchor, constant: 5
            ),
            muteBtn.widthAnchor.constraint(
                equalToConstant: muteBtn.frame.width),
            muteBtn.heightAnchor.constraint(
                equalToConstant: muteBtn.frame.height)
        ])
    }
//MARK: Button Function
    @objc private func showViewDidPressed(_ sender: UIButton) {
        if let videoUrl = url {
            pause()
            delegate?.presentAVPlayerVC(url: videoUrl, playFunction: play)
        }
    }
    @objc private func playPauseDidPressed(_ sender: UIButton) {
        guard let avPlayer = avPlayer else { return }
        switch avPlayer.timeControlStatus {
        case .paused:
            play(now: true)
        case .playing:
            pause()
        default:
            break
        }
    }
    @objc private func muteBtnPressed(_ sender: UIButton) {
        guard let avPlayer = avPlayer else { return }
        toggleMute(isMuted: !avPlayer.isMuted)
    }

//MARK: Cleaning up
    func cleanup() {
        pause()
        toggleMute(isMuted: true)
        stopExporter()
        urlAsset?.cancelLoading()
        url = nil
        urlAsset = nil
        playerItem = nil
        
        if avPlayer?.observationInfo != nil {
            avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        }
        avPlayer = nil
        spinner.stopAnimating()
        
        muteBtn.isHidden = true
        showViewBtn.isHidden = true
        playPauseBtn.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    deinit {
        cleanup()
    }
//MARK: UIStuff
    private struct Support {
        static let playerUIColor = UIColor.black.withAlphaComponent(0.25)
        static let playerUITint = UIColor.white
        static let playerUIFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
        static let muted = UIImage(systemName: "volume.slash")
        static let unMute = UIImage(systemName: "volume")
        static let play = UIImage(systemName: "play")
        static let pause = UIImage(systemName: "pause")
        static let expand = UIImage(systemName: "rectangle.expand.vertical")
    }
//MARK: Clear all videos in documents directory
    static func clearVideos() {
        if let docDir = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).last
        {
            do {
                let fileUrls = try FileManager.default.contentsOfDirectory(
                    at: docDir,
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles)
                for fileUrl in fileUrls {
                    if fileUrl.pathExtension == "mp4" {
                        try FileManager.default.removeItem(at: fileUrl)
                    }
                }
                print("Finished clearing all video in documents directory")
            } catch {
                print("Error Clearing Videos: \(error)")
                return
            }
        }
    }
}


