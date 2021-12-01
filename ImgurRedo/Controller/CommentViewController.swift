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
        cell.config(comment)
        
        if !comment.children.isEmpty {
            
            if comment.isCollapsed {
    //            cell.accessoryType = .none
                cell.backgroundColor = .blue
                cell.commentLabel.textColor = .white
            } else {
    //            cell.accessoryType = comment.children.isEmpty ? .none : .disclosureIndicator
                cell.backgroundColor = .lightGray
                cell.commentLabel.textColor = .black
            }
        } else {
            cell.backgroundColor = .white
            cell.commentLabel.textColor = .black
        }

        
        return cell
    }
}
extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = dataSource[indexPath.row]
        guard !comment.children.isEmpty else {
            return
        }
        
        
//        array.forEach{ print("level:\($0.level), value:\($0.value)") }
//        print("---------")
//        comment.forEachDepthFirst{ print("level:\($0.level), value:\($0.value)")}
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
            dataSource.insert(contentsOf: comment.children, at: indexPath.row + 1)
            comment.isCollapsed = true
        }
        tableView.reloadData()
    }
}
