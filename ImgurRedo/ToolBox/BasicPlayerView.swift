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
    private var url: URL?
    private var urlOnDisk: URL?
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var assetExporter: AVAssetExportSession?
    private var documentDir = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
    ).last!
    
    private var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
        return view
    }()
    private var showViewBtn = UIButton(type: .system)
    private var playPauseBtn = UIButton(type: .system)
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
            setupShowViewBtn()
            setupPlayPauseBtn()
        }
    }
//MARK: UI setup
    private func setupSpinner() {
        self.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    private func setupShowViewBtn() {
        let rectSize = CGSize(width: 30, height: 30)
        let buttonImage = UIImage(systemName: "mount.fill")

        showViewBtn.frame = CGRect(origin: .zero, size: rectSize)
        showViewBtn.translatesAutoresizingMaskIntoConstraints = false
        showViewBtn.clipsToBounds = true
        showViewBtn.tintColor = .white
        showViewBtn.backgroundColor = .darkGray
        showViewBtn.layer.cornerRadius = rectSize.height/3
        showViewBtn.isHidden = true
        
        var config = UIButton.Configuration.plain()
        config.image = buttonImage
        config.buttonSize = .mini
        showViewBtn.configuration = config
        
        showViewBtn.addTarget(self, action: #selector(showViewDidPressed(_:)), for: .touchUpInside)
        self.addSubview(showViewBtn)
        NSLayoutConstraint.activate([
            showViewBtn.trailingAnchor.constraint(
                equalTo: self.trailingAnchor, constant: -5
            ),
            showViewBtn.bottomAnchor.constraint(
                equalTo: self.bottomAnchor, constant: -5
            ),
            showViewBtn.heightAnchor.constraint(equalToConstant: rectSize.height),
            showViewBtn.widthAnchor.constraint(equalToConstant: rectSize.width)
        ])
    }
    private func setupPlayPauseBtn() {
        let btnSize = CGSize(width: 30, height: 30)
        let playImg = UIImage(systemName: "play.fill")
        
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.backgroundColor = .darkGray
        playPauseBtn.tintColor = .white
        playPauseBtn.frame = CGRect(origin: .zero, size: btnSize)
        playPauseBtn.clipsToBounds = true
        playPauseBtn.layer.cornerRadius = btnSize.height/3
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
            playPauseBtn.widthAnchor.constraint(equalToConstant: btnSize.width),
            playPauseBtn.heightAnchor.constraint(equalToConstant: btnSize.height)
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
        
        let firstCondition = !(self.url == url && avPlayer != nil && avPlayer?.error == nil)
        let secondCondition = !(urlOnDisk == fileUrl && assetExporter != nil && assetExporter?.error == nil)

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
                strongSelf.showViewBtn.isHidden = false
                strongSelf.playPauseBtn.isHidden = false
            }
            exportVideo(asset: asset)
            if shouldPlayImmediately {
                play()
            }
        }
    }
//MARK: Player Function
    func play() {
        guard let avPlayer = avPlayer, avPlayer.timeControlStatus == .paused else {
            return
        }
        avPlayer.play()
        updatePlayBtn()
    }
    func pause() {
        guard let avPlayer = avPlayer, avPlayer.timeControlStatus == .playing else {
            return
        }
        avPlayer.pause()
        updatePlayBtn()
    }
    func updatePlayBtn() {
        guard let status = avPlayer?.timeControlStatus else { return }
        let playImg = UIImage(systemName: "play.fill")
        let pauseImg = UIImage(systemName: "pause.fill")
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
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
            strongSelf.playPauseBtn.setImage(
                newImage,
                for: .normal
            )
        }
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
                switch exporter.status {
                case .waiting:
                    print("Waiting to export Video")
                case .exporting:
                    print("Exporting video")
                case .completed:
                    print("Export completed")
                    strongSelf.urlOnDisk = exporter.outputURL
                case .failed:
                    print("Failed to export video")
                case .cancelled:
                    print("Cancelled exporting video")
                default:
                    print("Other options")
                }
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


