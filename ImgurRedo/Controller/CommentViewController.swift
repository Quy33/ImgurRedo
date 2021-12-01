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

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = commentsGot
        commentTableView.dataSource = self
        commentTableView.delegate = self
        registerCell()
    }
    
    func registerCell() {
        let nib = UINib(nibName: CommentCell.identifier, bundle: nil)
        commentTableView.register(nib, forCellReuseIdentifier: CommentCell.identifier)
    }
}
//MARK: TableView Stuff
extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        
        let comment = dataSource[indexPath.row]
        cell.config(text: comment.value)
        cell.accessoryType = comment.children.isEmpty ? .none : .disclosureIndicator
        
        return cell
    }
}
extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = dataSource[indexPath.row]
        print(comment.level)
        guard !comment.children.isEmpty && !comment.isCollapsed else {
            return
        }
        dataSource.insert(contentsOf: comment.children, at: indexPath.row + 1)
        dataSource[indexPath.row].isCollapsed = true
        tableView.reloadData()
    }
}
