//
//  CommentViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit
import CoreMedia
import AVFoundation
import AVKit

class CommentViewController: UIViewController {

    static let identifier = "CommentViewController"
    var commentsGot: [Comment] = []
    private var dataSource: [Comment] = []
    private let networkManager = NetWorkManager()
    private let playerVC = AVPlayerViewController()
    private var playerViewMethod: ((Bool)->Void)?

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        playerVC.delegate = self
        dataSource = commentsGot
        
        registerCell()
        commentTableView.dataSource = self
        commentTableView.delegate = self
        detectMediaLink()
        commentTableView.reloadData()
        downloadCellImage()
    }
    //Temp fix
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !dataSource.isEmpty else { return }
        for (index,data) in dataSource.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            if let commentCell = (commentTableView.cellForRow(at: indexPath) as? CommentCell) {
                guard !playerVC.isBeingPresented else { return }
                data.isCollapsed = false
                if data.hasVideoLink {
                    commentCell.cleanup()
                }
            }
        }
    }
    
    private func registerCell() {
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
    }
    
//MARK: Functions to detect & download comments image link
    private func detectMediaLink() {
        for comment in dataSource {
            let links = networkManager.detectLinks(text: comment.value)
            for link in links {
                if link.contains(NetWorkManager.baseImgLink) {
                    if let contentType = link.searchExtension() {
                        var urlString = ""
                        switch contentType {
                        case .mp4, .gif, .gifv:
                            urlString = link.replacingOccurrences(
                                of: contentType.rawValue,
                                with: "mp4"
                            )
                            if let url = URL(string: urlString) {
                                let thumbnailStr = ToolBox.concatStr(string: link, size: .mediumThumbnail)
                                let thumbnailUrl = URL(string: thumbnailStr) ?? ToolBox.blankURL
                                comment.videoData = Comment.VideoData(thumbnail: nil, thumbnailLink: thumbnailUrl, link: url)
                                comment.hasVideoLink = true
                            }
                        case .jpg ,.png, .jpeg:
                            urlString = link
                            if let url = URL(string: urlString) {
                                comment.imageData = Comment.ImageData(image: nil, link: url)
                                comment.hasImageLink = true
                            }
                        }
                        comment.value = comment.value.replacingOccurrences(of: link, with: "")
                        comment.contentType = contentType
                    }
                }
            }
        }
    }
    
    private func downloadCellImage() {
        Task {
            for (index,comment) in self.dataSource.enumerated() {
                let imageBool = (comment.hasImageLink
                                 && comment.imageData?.image == nil)
                let videoBool = (comment.hasVideoLink
                                 && comment.videoData?.thumbnail == nil)
                guard imageBool || videoBool else { continue }
                
                let cellWidth = comment.calculateWidth()
                do {
                    if let imageLink = comment.imageData?.link {
                        let image = try await networkManager.singleDownload(url: imageLink)
                        let resizedImage = image.drawImage(toWidth: cellWidth)
                        comment.imageData?.image = resizedImage
                    } else if let thumbnailLink = comment.videoData?.thumbnailLink {
                        let image = try await networkManager.singleDownload(url: thumbnailLink)
                        let thumbnail = image.drawBlankThumbnail(withWidth: cellWidth)
                        comment.videoData?.thumbnail = thumbnail
                    }
                    updateCell(for: index)
                } catch {
                    print(error)
                    continue
                }
            }
        }
    }
    
    private func updateCell(for row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        DispatchQueue.main.async {
            self.commentTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private func setNavBar(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .lightGray
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
}
//MARK: TableView Stuff
extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = dataSource[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell
        else {
            return UITableViewCell()
        }
        cell.config(comment)
        cell.setPlayerViewDelegate(self)
        return cell
    }
}
extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = dataSource[indexPath.row]
        guard let commentCell = (tableView.cellForRow(at: indexPath) as? CommentCell),
            (!comment.children.isEmpty) else { return }
        var indexes: [IndexPath] = []
        if comment.isCollapsed {
            comment.traverse(container: &dataSource, selected: comment) { item, selected, cont  in
                for (index,comment) in cont.enumerated() {
                    if comment.id == selected.id {
                        continue
                    } else if comment.id == item.id {
                        comment.isCollapsed = false
                        let indexToRemove = IndexPath(row: index, section: 0)
                        indexes.append(indexToRemove)
                    }
                }
            }

            let lowerRange = indexes.first!
            let upperRange = indexes.last!
            dataSource.removeSubrange(lowerRange.row...upperRange.row)
            tableView.deleteRows(at: indexes, with: .none)

            comment.isCollapsed = false
        } else {
            let next = IndexPath(row: indexPath.row + 1, section: 0)
            dataSource.insert(contentsOf: comment.children, at: next.row)
            detectMediaLink()

            let upperBound = next.row + comment.children.count
            for index in next.row..<upperBound {
                let newIndex = IndexPath(row: index, section: 0)
                indexes.append(newIndex)
            }
            tableView.insertRows(at: indexes, with: .none)
            comment.isCollapsed = true
        }
        commentCell.updateCollapsed(isCollapsed: comment.isCollapsed, count: comment.children.count, isTop: comment.isTop)
        downloadCellImage()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let commentCell = cell as? CommentCell else { return }
        let comment = dataSource[indexPath.row]
        if comment.hasVideoLink {
            commentCell.prepareToPlay(url: comment.videoData!.link, shouldPlayImmediately: true)
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let commentCell = cell as? CommentCell, (indexPath.row < dataSource.endIndex) else { return }
        let comment = dataSource[indexPath.row]
        if comment.hasVideoLink {
            commentCell.cleanup()
        }
    }
}
//MARK: Video Player Extension
extension CommentViewController: BasicPlayerViewDelegate {
    func presentAVPlayerVC(url: URL, playFunction: @escaping ((Bool) -> Void)) {
        let player = AVPlayer(url: url)
        playerVC.player = player
        playerViewMethod = playFunction
        self.present(playerVC, animated: true) {
            player.play()
        }
    }
}
extension CommentViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let playerViewMethod = playerViewMethod {
            playerViewMethod(false)
            self.playerViewMethod = nil
        }
    }
}
//MARK: Extension to calculateScreenWidth of a Comment cell
extension Comment {
    func calculateWidth() -> CGFloat {
        let leftBarW = self.isTop ? 0 : CommentCell.barWidth
        let spacing = CGFloat(self.level) * CommentCell.outerStvSpacing
        let screenWidth = UIScreen.main.bounds.width
        let result = screenWidth - leftBarW - spacing
        
        return result
    }
}
