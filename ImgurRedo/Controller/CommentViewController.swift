//
//  CommentViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit
import CoreMedia
import AVFoundation

class CommentViewController: UIViewController {

    static let identifier = "CommentViewController"
    var commentsGot: [Comment] = []
    private var dataSource: [Comment] = []
    private let networkManager = NetWorkManager()

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
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
        dataSource.forEach{ $0.isCollapsed = false }
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
                                comment.videoData = Comment.VideoData(link: url)
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
                guard comment.hasImageLink && comment.imageData?.image == nil else {
                    continue
                }
                if let link = comment.imageData?.link {
                    do {
                        let newImage = try await networkManager.singleDownload(url: link)
                        let cellWidth = calculateWidth(comment)
                        let resizedImage = newImage.drawImage(toWidth: cellWidth)
                        comment.imageData?.image = resizedImage
                        updateCell(for: index)
                    } catch {
                        print(error)
                        continue
                    }
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
    private func calculateWidth(_ comment: Comment) -> CGFloat {
        let leftBarW = comment.isTop ? 0 : CommentCell.separatorWidth
        let spacing = CGFloat(comment.level) * CommentCell.outerStvSpacing
        let screenWidth = self.view.frame.width
        let result = screenWidth - leftBarW - spacing
        
        return result
    }
}
//MARK: TableView Stuff
extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !dataSource.isEmpty else {
            return 1
        }
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = dataSource[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell
        else {
            return UITableViewCell()
        }
        cell.config(comment)
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
            tableView.deleteRows(at: indexes, with: .fade)

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
            tableView.insertRows(at: indexes, with: .fade)
            comment.isCollapsed = true
        }
        commentCell.updateCollapsed(isCollapsed: comment.isCollapsed, count: comment.children.count, isTop: comment.isTop)
        downloadCellImage()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let commentCell = cell as? CommentCell else { return }
        let comment = dataSource[indexPath.row]
        if comment.hasVideoLink {
            if let visibleRows = tableView.indexPathsForVisibleRows {
                visibleRows.forEach {
                    if indexPath == $0 {
                        DispatchQueue.main.async {
                            commentCell.play()
                        }
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let commentCell = cell as? CommentCell else { return }
        let comment = dataSource[indexPath.row]
        comment.imageData?.image = nil
        if comment.hasVideoLink {
            DispatchQueue.main.async {
                commentCell.cleanup()
            }
        }
    }
}

