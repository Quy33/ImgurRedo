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
    var linkGot: URL?
    private var dataSource: [Comment] = []
    private let networkManager = NetWorkManager()
    private let playerVC = AVPlayerViewController()
    private var playerViewMethod: ((Bool)->Void)?
    private var loadCommentsError: Error?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
        view.backgroundColor = .black
        view.hidesWhenStopped = true
        return view
    }()
    private let errorStv: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        view.axis = .vertical
        view.backgroundColor = .clear
        view.spacing = 10
        view.distribution = .fillProportionally
        return view
    }()
    private let errorLbl: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error"
        return label
    }()
    private let reloadErrBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .gray
        button.tintColor = .white
        button.setTitle("Reload", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let reloadBtnFrame: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        
        playerVC.delegate = self
        reloadErrBtn.addTarget(self, action: #selector(reloadErrorBtnPressed(_:)), for: .touchUpInside)
        
        registerCell()
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        requestData()
    }
    //Clean up video cell
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !dataSource.isEmpty else { return }
        for (index,data) in dataSource.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            if let commentCell = (commentTableView.cellForRow(at: indexPath) as? CommentCell) {
                if !(playerVC.isBeingPresented) {
                    if data.hasVideoLink {
                        commentCell.cleanup()
                    }
                }
            }
        }
    }
    
    private func registerCell() {
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
    }
//MARK: Comment API Call
    private func requestData() {
        guard let url = linkGot else { return }
        showLoading(isLoading: true)
        Task {
            do {
                let rawData = try await networkManager.requestComment(url)
                for commentData in rawData.data {
                    var array: [Comment] = []
                    appendNode(container: &array, commentData) { $0.append(Comment(data: $1))
                    }
                    let result = makeTree(array)
                    dataSource.append(result)
                }
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showLoading(isLoading: false)
                    strongSelf.detectMediaLink()
                    strongSelf.commentTableView.reloadData()
                }
                downloadCellImage()
            } catch {
                print("Failed to fetch comments: \(error)")
                loadCommentsError = error
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showLoading(isLoading: false)
                    strongSelf.showError()
                }
            }
        }
    }
//MARK: Transform rawData to Comment
    func appendNode(container: inout [Comment], _ data: RawCommentData,_ visit: (inout [Comment], RawCommentData)->Void ) {
        visit(&container, data)
        data.children.forEach {
            appendNode(container: &container, $0, visit)
        }
    }
    func makeTree(_ container: [Comment]) -> Comment {
        for (index,item) in container.enumerated() {
            var nextCount = index + 1
            while nextCount < container.count {
                if item.id == container[nextCount].parentId {
                    item.add(container[nextCount])
                }
                nextCount += 1
            }
        }
        return container.first!
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

//MARK: UI Functions
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
    
    private func showLoading(isLoading: Bool) {
        if isLoading {
            commentTableView.isHidden = isLoading
            view.addSubview(activityIndicator)
            NSLayoutConstraint.activate([
                activityIndicator.topAnchor.constraint(
                    equalTo: view.topAnchor),
                activityIndicator.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor),
                activityIndicator.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor),
                activityIndicator.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor)
            ])
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            commentTableView.isHidden = isLoading
        }
    }
    private func showError() {
        if let error = loadCommentsError {
            errorLbl.text = error.localizedDescription
        }
        
        view.addSubview(errorStv)
        errorStv.addArrangedSubview(errorLbl)
        errorStv.addArrangedSubview(reloadBtnFrame)
        reloadBtnFrame.addSubview(reloadErrBtn)
        
        NSLayoutConstraint.activate([
            errorStv.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.75),
            errorStv.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.25),
            errorStv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorStv.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLbl.widthAnchor.constraint(equalTo: errorStv.widthAnchor),
            errorLbl.topAnchor.constraint(equalTo: errorStv.topAnchor),
            reloadBtnFrame.heightAnchor.constraint(equalToConstant: 50),
            reloadBtnFrame.bottomAnchor.constraint(equalTo: errorStv.bottomAnchor),
            reloadErrBtn.topAnchor.constraint(equalTo: reloadBtnFrame.topAnchor, constant: 5),
            reloadErrBtn.bottomAnchor.constraint(equalTo: reloadBtnFrame.bottomAnchor, constant: -5),
            reloadErrBtn.leadingAnchor.constraint(equalTo: reloadBtnFrame.leadingAnchor, constant: 20),
            reloadErrBtn.trailingAnchor.constraint(equalTo: reloadBtnFrame.trailingAnchor, constant: -20)
        ])
    }
//MARK: Button function
    @objc private func reloadErrorBtnPressed(_ sender: UIButton) {
        reloadErrBtn.removeFromSuperview()
        reloadBtnFrame.removeFromSuperview()
        errorLbl.removeFromSuperview()
        errorStv.removeFromSuperview()
        requestData()
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
