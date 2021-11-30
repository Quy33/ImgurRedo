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
    private var isAll = true

    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = commentsGot
        commentTableView.dataSource = self
        commentTableView.delegate = self
    }
    
}
//MARK: TableView Stuff
extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard !dataSource.isEmpty else {
            return cell
        }
        let comment = dataSource[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = comment.value
        
        cell.accessoryType = comment.children.isEmpty ? .none : .disclosureIndicator
        cell.contentConfiguration = config
        
        return cell
    }
}
extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = dataSource[indexPath.row]
        if !comment.children.isEmpty {
            dataSource = comment.children
            tableView.reloadData()
        }
    }
}
