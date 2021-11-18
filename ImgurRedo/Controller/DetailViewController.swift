//
//  DetailViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView?
    
    static let identifier = "DetailViewController"
    
    var galleryGot = (isAlbum: false, id: "aaaa")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView?.dataSource = self
        detailTableView?.delegate = self
        registerCell(tableView: detailTableView)
        detailTableView?.rowHeight = 80
        // Do any additional setup after loading the view.
    }

    @IBAction func testPressed(_ sender: UIButton) {
        detailTableView?.reloadData()
    }
    
    private func registerCell(tableView: UITableView?) {
        guard let tableView = tableView else {
            return
        }
        let nib = UINib(nibName: DetailTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DetailTableViewCell.identifier)
    }
}
//MARK: TableView Data Source
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as! DetailTableViewCell
        return cell
    }
}
//MARK: TableView Delegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let detailCell = cell as? DetailTableViewCell {
            print(detailCell.outerFrame?.frame.width)
        }
    }
}
