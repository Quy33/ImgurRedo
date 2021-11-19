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
    private let networkManager = NetWorkManager()
    private var imageItem = DetailModel()
    private var albumItem = DetailAlbumModel()
    private var heights: [CGFloat] = []
    private var isCached = false
    
//    var galleryGot = (isAlbum: true, id: "n2j8gBs")
//    var galleryGot = (isAlbum: true, id: "Xc9G5qf") /// Stacks
//    var galleryGot = (isAlbum: true, id: "azlYGAV")
//    var galleryGot = (isAlbum: false, id: "Dkmocay") /// Image
    var galleryGot = (isAlbum: true, id: "2eOWNGV")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(galleryGot)
        detailTableView?.dataSource = self
        detailTableView?.delegate = self
        registerCell(tableView: detailTableView)
        loadDetails()
    }
    
    private func loadDetails(){
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
    //MARK: Height Calculation
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
            
            let configuration: ConfigTuple = (top: imageItem.title, title: nil, image: imageItem.image, description: nil, bottom: imageItem.description, isBottom: true)
            
            cell.config(configuration)
            
        } else {
            let albumImageItem = albumItem.images[indexPath.row]
            let itemCount = albumItem.images.count
            var configuration: ConfigTuple = (top: albumItem.title, title: albumImageItem.title, image: albumImageItem.image, description: albumImageItem.description, bottom: albumItem.description, isBottom: false)
            
            if itemCount == 1 {
                configuration.title = albumImageItem.title
                configuration.description = albumImageItem.description
                configuration.isBottom = true
                
                cell.config(configuration)
            } else {
                switch indexPath.row {
                case 0:
                    configuration.bottom = nil
                    cell.config(configuration)
                case itemCount - 1:
                    configuration.top = nil
                    configuration.isBottom = true
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
            if !heights.isEmpty {
                if !isCached {
                    calculateElementHeights(cell: detailCell)
                    isCached = true
                    detailTableView?.reloadData()
                }
            }
        }
    }
    
    func calculate(config: ConfigTuple,cell: DetailTableViewCell, hPadding: CGFloat, vPadding: CGFloat) -> CGFloat {
        let width = cell.outerFrame?.frame.width ?? 0
        let top = config.top 
        let title = config.title
        let description = config.description
        let bottom = config.bottom
        
        let topLabel = calculateLabelFrame(text: top, width: width, hPadding: hPadding, vPadding: vPadding)
        let titleLabel = calculateLabelFrame(text: title, width: width, hPadding: hPadding, vPadding: vPadding)
        let descLabel = calculateLabelFrame(text: description, width: width, hPadding: hPadding, vPadding: vPadding)
        let bottomLabel = calculateLabelFrame(text: bottom, width: width, hPadding: hPadding, vPadding: vPadding)
        let image = calculateImageRatio(config.image, frameWidth: width)
        var separator = cell.separatorFrame?.frame.height ?? 0
        separator = config.isBottom ? 0 : separator
        
        let result = topLabel.height + titleLabel.height + descLabel.height + bottomLabel.height + image.height + separator
        return result
        
    }
    private func calculateElementHeights(cell: DetailTableViewCell) {
        let vPadding: CGFloat = 20
        let hPadding: CGFloat = 10
        
        if galleryGot.isAlbum {
            let itemCount = albumItem.images.count
            var albumConfig: ConfigTuple = (top: albumItem.title,
                                       title: nil,
                                       image: ToolBox.placeHolderImg,
                                       description: nil,
                                       bottom: albumItem.description, isBottom: false)
            
            if itemCount == 1 {
                let item = albumItem.images[0]
                albumConfig.title = item.title
                albumConfig.description = item.description
                albumConfig.image = item.image
                albumConfig.isBottom = true
                
                heights[0] = calculate(config: albumConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
            } else {
                let items = albumItem.images
                for (index,item) in items.enumerated() {
                    albumConfig.title = item.title
                    albumConfig.description = item.description
                    albumConfig.image = item.image
                    
                    switch index {
                    case 0:
                        albumConfig.bottom = nil
                        heights[index] = calculate(config: albumConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
                    case itemCount - 1:
                        albumConfig.top = nil
                        albumConfig.isBottom = true
                        heights[index] = calculate(config: albumConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
                    default:
                        albumConfig.top = nil
                        albumConfig.bottom = nil
                        heights[index] = calculate(config: albumConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
                    }
                }
            }
        } else {
            let imageConfig: ConfigTuple = (top: imageItem.title,
                          title: nil,
                          image: imageItem.image,
                          description: nil,
                          bottom: imageItem.description,
                          isBottom: true)
            heights[0] = calculate(config: imageConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !heights.isEmpty else {
            return 0
        }
        return heights[indexPath.row]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DetailTableViewCell {
            print(cell.frame.height)
        }
    }
}
