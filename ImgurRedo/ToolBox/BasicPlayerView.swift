//
//  BasicPlayerView.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/12/2021.
//

import UIKit
import AVKit
import AVFoundation

protocol BasicPlayerViewDelegate {
    func presentAVPlayerVC(url: URL,playFunction:@escaping (()->Void))
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
    
    private let playerUIColor = UIColor.black.withAlphaComponent(0.5)
    private let playerUITint = UIColor.white
    private let playerUIFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
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
            if showControls {
                setupShowViewBtn()
                setupPlayPauseBtn()
            }
        }
    }
//MARK: UI setup
    private func setupSpinner() {
        spinner.frame = playerUIFrame
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = playerUITint
        spinner.backgroundColor = playerUIColor
        spinner.clipsToBounds = true
        spinner.layer.cornerRadius = spinner.frame.height / 2
        self.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spinner.widthAnchor.constraint(
                equalTo: self.widthAnchor, multiplier: 0.1),
            spinner.heightAnchor.constraint(
                equalTo: self.widthAnchor, multiplier: 0.1)
        ])
    }
    private func setupShowViewBtn() {
        let buttonImage = UIImage(systemName: "mount.fill")

        showViewBtn.frame = playerUIFrame
        showViewBtn.translatesAutoresizingMaskIntoConstraints = false
        showViewBtn.clipsToBounds = true
        showViewBtn.tintColor = playerUITint
        showViewBtn.backgroundColor = playerUIColor
        showViewBtn.layer.cornerRadius = playerUIFrame.height/3
        showViewBtn.isHidden = true
        
        var config = UIButton.Configuration.plain()
        config.image = buttonImage
        config.buttonSize = .mini
        showViewBtn.configuration = config
        
        showViewBtn.addTarget(self, action: #selector(showViewDidPressed(_:)), for: .touchUpInside)
        self.addSubview(showViewBtn)
        NSLayoutConstraint.activate([
            showViewBtn.trailingAnchor.constraint(
                equalTo: self.trailingAnchor, constant: -5),
            showViewBtn.bottomAnchor.constraint(
                equalTo: self.bottomAnchor, constant: -5),
            showViewBtn.widthAnchor.constraint(
                equalTo: self.widthAnchor, multiplier: 0.1),
            showViewBtn.heightAnchor.constraint(
                equalTo: self.widthAnchor, multiplier: 0.1)
        ])
    }
    private func setupPlayPauseBtn() {
        let playImg = UIImage(systemName: "play.fill")
        
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.backgroundColor = playerUIColor
        playPauseBtn.tintColor = playerUITint
        playPauseBtn.frame = playerUIFrame
        playPauseBtn.clipsToBounds = true
        playPauseBtn.layer.cornerRadius = playPauseBtn.frame.height/3
        playPauseBtn.isHidden = true
        playPauseBtn.setImage(playImg, for: .normal)
        
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
                equalTo: self.widthAnchor, multiplier: 0.1),
            playPauseBtn.heightAnchor.constraint(
                equalTo: self.widthAnchor, multiplier: 0.1)
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
        guard let avPlayer = avPlayer else {
            return
        }
        switch avPlayer.timeControlStatus {
        case .paused:
            play()
        case .playing:
            pause()
        default:
            break
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
            playerItem = item
            avPlayer = player
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.spinner.stopAnimating()
                strongSelf.spinner.removeFromSuperview()
                if strongSelf.showControls {
                    strongSelf.showViewBtn.isHidden = false
                    strongSelf.playPauseBtn.isHidden = false
                }
            }
            exportVideo(asset: asset)
            if shouldPlayImmediately {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    player.playImmediately(atRate: 1.0)
                    strongSelf.updatePlayBtn()
                }
            }
        }
    }
//MARK: Player Function
    func play() {
        guard let avPlayer = avPlayer, avPlayer.timeControlStatus == .paused else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.avPlayer?.play()
            strongSelf.updatePlayBtn()
        }
    }
    func pause() {
        guard let avPlayer = avPlayer, avPlayer.timeControlStatus == .playing else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            avPlayer.pause()
            strongSelf.updatePlayBtn()
        }
        
    }
    func updatePlayBtn() {
        guard let status = avPlayer?.timeControlStatus else { return }
        let playImg = UIImage(systemName: "play.fill")
        let pauseImg = UIImage(systemName: "pause.fill")
        var newImage: UIImage?
        switch status {
        case .paused:
            newImage = playImg
        case .waitingToPlayAtSpecifiedRate:
            newImage = pauseImg
        case .playing:
            newImage = pauseImg
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
        guard (notification.object as? AVPlayerItem == playerItem) else {
            return
        }
        avPlayer?.seek(to: .zero)
        avPlayer?.play()
    }
    private func exportVideo(asset: AVURLAsset) {
        let outputUrl = self.documentDir.appendingPathComponent(asset.url.lastPathComponent)
        guard (asset.isExportable
               && !FileManager.default.fileExists(atPath: outputUrl.path) && assetExporter?.status != .exporting)
        else { return }
        
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
//MARK: Cleaning up
    func cleanup() {
        pause()
        stopExporter()
        urlAsset?.cancelLoading()
        url = nil
        urlAsset = nil
        playerItem = nil
        avPlayer = nil
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    deinit {
        cleanup()
    }
}


