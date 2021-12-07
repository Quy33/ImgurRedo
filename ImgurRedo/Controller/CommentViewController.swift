//
//  CommentViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit

class CommentViewController: UIViewController {

    static let identifier = "CommentViewController"
    var commentsGot: [Comment] = []
    private var dataSource: [Comment] = []
    private let networkManager = NetWorkManager()

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = commentsGot
        
        registerCell()
        commentTableView.dataSource = self
        commentTableView.delegate = self
        getImageLink()
        downloadCellImage()
//        commentTableView.rowHeight = 200
    }
    //Temp fix
    override func viewWillDisappear(_ animated: Bool) {
        dataSource.forEach{ $0.isCollapsed = false }
    }
    
    private func registerCell() {
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
    }
    private func detectImageLink(with text: String) -> String? {
        var result: String?
        let links = networkManager.detectLinks(text: text)
        links.forEach{
            if $0.contains(NetWorkManager.baseImgLink) {
                result = $0
            }
        }
        return result
    }
    private func getImageLink() {
        for (index,comment) in dataSource.enumerated() {
            if var urlString = detectImageLink(with: comment.value) {
                guard let lastElements = urlString.lastIndex(of: "/") else {
                    return
                }
                let endPoint = urlString.endIndex
                let subString = urlString[lastElements..<endPoint]
                urlString = NetWorkManager.baseImgLink + subString
                
                dataSource[index].value = comment.value.replacingOccurrences(of: urlString, with: "")
                comment.imageLink = ToolBox.concatStr(string: urlString, size: .hugeThumbnail)
                comment.hasImageLink = true
            }
        }
    }
    private func downloadCellImage() {
        Task {
            for (index,comment) in self.dataSource.enumerated() {
                if comment.hasImageLink {
                    do {
                        guard let url = URL(string: comment.imageLink!) else {
                            throw NetworkingError.invalidData
                        }
                        comment.image = try await networkManager.singleDownload(url: url)
                        DispatchQueue.main.async {
                            self.commentTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                    } catch {
                        print(error)
                        continue
                    }
                }
            }
        }
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
            dataSource.insert(contentsOf: comment.children, at: next.row)
            comment.isCollapsed = true
        }
        getImageLink()
        tableView.reloadData()
        downloadCellImage()
    }
}
