//
//  DetailViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import UIKit

typealias ConfigTuple = (top: String?, title: String?, image: UIImage, description: String?, bottom: String?)

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView?
    
    static let identifier = "DetailViewController"
    private let networkManager = NetWorkManager()
    private var imageItem = DetailModel()
    private var albumItem = DetailAlbumModel()
    private var heights: [CGFloat] = []
    private var isCached = false
    
//    var galleryGot = (isAlbum: true, id: "n2j8gBs")
//    var galleryGot = (isAlbum: true, id: "Xc9G5qf") /// Stacks
    var galleryGot = (isAlbum: true, id: "azlYGAV")
//    var galleryGot = (isAlbum: false, id: "Dkmocay") /// Image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(galleryGot)
        detailTableView?.dataSource = self
        detailTableView?.delegate = self
        registerCell(tableView: detailTableView)
        call()
        // Do any additional setup after loading the view.
    }
    
    private func call(){
        Task {
            do {
                let model = try await networkManager.requestDetail(isAlbum: galleryGot.isAlbum, id: galleryGot.id)
                if galleryGot.isAlbum {
                    albumItem = DetailAlbumModel(model.data)
                    let urls = albumItem.images.map{ $0.url }
                    let images = try await networkManager.batchesDownload(urls: urls)

                    for (index,item) in albumItem.images.enumerated() {
                        item.image = images[index]
                    }
                    heights = .init(repeating: 0, count: albumItem.images.count)
                } else {
                    imageItem = DetailModel(model.data)
                    imageItem.image = try await networkManager.singleDownload(url: imageItem.url)
                    heights = [0]
                }
                DispatchQueue.main.async {
                    self.detailTableView?.reloadData()
                }
            } catch {
                print("Error: \(error)")
            }
        }
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
        guard !heights.isEmpty else {
            return 0
        }
        if galleryGot.isAlbum {
            return albumItem.images.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as! DetailTableViewCell
        guard !heights.isEmpty else {
            return cell
        }
        
        
        if !galleryGot.isAlbum {
            
            let configuration: ConfigTuple = (top: imageItem.title, title: nil, image: imageItem.image, description: nil, bottom: imageItem.title)
            
            cell.config(configuration)
        } else {
            let albumImageItem = albumItem.images[indexPath.row]
            let itemCount = albumItem.images.count
            var configuration: ConfigTuple = (top: albumItem.title, title: albumImageItem.title, image: albumImageItem.image, description: albumImageItem.description, bottom: albumItem.description)
            
            if itemCount == 1 {
                configuration.title = nil
                configuration.description = nil
                
                cell.config(configuration)
            } else {
                switch indexPath.row {
                case 0:
                    configuration.bottom = nil
                    cell.config(configuration)
                case itemCount - 1:
                    configuration.top = nil
                    cell.config(configuration)
                default:
                    configuration.top = nil
                    configuration.bottom = nil
                    cell.config(configuration)
                }
            }
        }
        
        return cell
    }
}
//MARK: TableView Delegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let detailCell = cell as? DetailTableViewCell {
            if !isCached {
                calculateHeights()
            }
//            print(detailCell.outerFrame?.frame.width)
        }
    }
}
