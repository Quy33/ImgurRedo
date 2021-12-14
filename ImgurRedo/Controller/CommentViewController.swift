//
//  CommentViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit
import CoreMedia

class CommentViewController: UIViewController {

    static let identifier = "CommentViewController"
    var commentsGot: [Comment] = []
    private var dataSource: [Comment] = [] {
        didSet{
            detectMediaLink()
            commentTableView.reloadData()
            downloadCellImage()
        }
    }
    private let networkManager = NetWorkManager()

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        dataSource = commentsGot
        
        registerCell()
        commentTableView.dataSource = self
        commentTableView.delegate = self
    }
    //Temp fix
    override func viewWillDisappear(_ animated: Bool) {
        dataSource.forEach{ $0.isCollapsed = false }
    }
    
    private func registerCell() {
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
    }
//MARK: Functions to detect & download comments image link
    
//    private func detectImageLink() {
//        for comment in dataSource {
//            let links = networkManager.detectLinks(text: comment.value)
//            for link in links {
//                if link.contains(NetWorkManager.baseImgLink) {
//                    if let contentType = link.searchExtension() {
//                        var urlString = ""
//                        switch contentType {
//                        case .png, .jpeg, .jpg:
//                            urlString = link
//                        case .mp4, .gif:
//                            urlString = ToolBox.concatStr(string: link, size: .hugeThumbnail)
//                        }
//
//                        guard let url = URL(string: urlString) else {
//                            continue
//                        }
//
//                        comment.value = comment.value.replacingOccurrences(of: link, with: "")
//                        comment.contentType = contentType
//                        comment.imageLink = url
//                        comment.hasImageLink = true
//                    }
//                }
//            }
//        }
//    }
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
                                comment.videoLink = url
                                comment.hasVideoLink = true
                            }
                        default:
                            urlString = link
                            if let url = URL(string: urlString) {
                                comment.imageLink = url
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
    
    private func updateCell(for row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        DispatchQueue.main.async {
            self.commentTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private func downloadCellImage() {
        Task {
            for (index,comment) in self.dataSource.enumerated() {
                guard comment.hasImageLink else {
                    continue
                }
                if let link = comment.imageLink {
                    do {
                        comment.image = try await networkManager.singleDownload(url: link)
                        updateCell(for: index)
                    } catch {
                        print(error)
                        continue
                    }
                }
            }
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
        guard !dataSource.isEmpty else {
            return 1
        }
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = dataSource[indexPath.row]
        let cell = CommentCell.init(style: .default, reuseIdentifier: CommentCell.identifier, comment: comment)
        return cell
    }
}
extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = dataSource[indexPath.row]
        guard !comment.children.isEmpty else {
            return
        }
        if comment.isCollapsed {
            comment.traverse(container: &dataSource, selected: comment) { item, selected, cont  in
                for (index,comment) in cont.enumerated() {
                    if comment.id == selected.id {
                        continue
                    } else if comment.id == item.id {
                        comment.isCollapsed = false
                        cont.remove(at: index)
                    }
                }
            }
            comment.isCollapsed = false
        } else {
            let next = IndexPath(row: indexPath.row + 1, section: 0)
            comment.isCollapsed = true
            dataSource.insert(contentsOf: comment.children, at: next.row)
        }
    }
}

