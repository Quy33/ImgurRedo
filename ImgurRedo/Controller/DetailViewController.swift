//
//  DetailViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import UIKit
import AVKit
import AVFoundation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView?
    @IBOutlet weak var loadingFrame: UIView?
    @IBOutlet weak var errorLabel: UILabel?
    @IBOutlet weak var commentsBtn: UIButton!
    
    static let identifier = "DetailViewController"
    private let networkManager = NetWorkManager()
    private var imageItem = DetailModel()
    private var albumItem = DetailAlbumModel()
    private var heights: [CGFloat] = []
    private var isCached = false
    private var errorTuple: ErrorTuple = (isError: false, description: nil)
    private var comments: [Comment] = []
        
    var galleryGot = (isAlbum: true, id: "2eOWNGV")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView?.dataSource = self
        detailTableView?.delegate = self
        detailTableView?.refreshControl = UIRefreshControl()
        detailTableView?.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        registerCell(tableView: detailTableView)
        
        DetailModel.setQuality(isThumbnail: true, size: .mediumThumbnail)
        
        loadingFrame?.isHidden = true
        loadDetails()
    }
//MARK: Networking Call
    private func loadDetails(){
        loadUI(true)
        Task {
            do {
                let metaData = try await networkManager.requestData(isAlbum: galleryGot.isAlbum, id: galleryGot.id)
                
                let detailModel = metaData.detailData
                
                if galleryGot.isAlbum {
                    albumItem = DetailAlbumModel(detailModel.data)
                    let urls = albumItem.images.map{ $0.url }
                    let images = try await networkManager.batchesDownload(urls: urls)
                    for (index,item) in albumItem.images.enumerated() {
                        item.image = images[index]
                    }
                    heights = .init(repeating: 0, count: albumItem.images.count)
                } else {
                    imageItem = DetailModel(detailModel.data)
                    imageItem.image = try await networkManager.singleDownload(url: imageItem.url)
                    heights.append(0)
                }
                DispatchQueue.main.async {
                    self.loadUI(false)
                    self.detailTableView?.reloadData()
                }
                //Comments
                let commentsData = metaData.commentData
                for commentData in commentsData.data {
                    var array: [Comment] = []
                    appendNode(container: &array, commentData) { $0.append(Comment(data: $1)) }
                    let result = makeTree(array)
                    comments.append(result)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    self.loadUI(false)
                    self.errorTuple = (isError: true, description: error.localizedDescription)
                    self.updateError(errorTuple: self.errorTuple)
                }
            }
        }
    }
//MARK: Comments Functions
    func appendNode(container: inout [Comment], _ data: CommentData,_ visit: (inout [Comment], CommentData)->Void ) {
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
//MARK: Cell registration
    private func registerCell(tableView: UITableView?) {
        guard let tableView = tableView else {
            return
        }
        let nib = UINib(nibName: DetailTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DetailTableViewCell.identifier)
    }
//MARK: Call to update UI
    private func updateError(errorTuple: ErrorTuple) {
        errorLabel?.text = errorTuple.description
        if errorTuple.isError {
            loadingFrame?.isHidden = false
            detailTableView?.isHidden = true
        } else {
            loadingFrame?.isHidden = true
            detailTableView?.isHidden = false
        }
    }
    @objc private func didPullToRefresh() {
        reload()
    }
    private func reload() {
        albumItem = DetailAlbumModel()
        imageItem = DetailModel()
        isCached = false
        detailTableView?.reloadData()
        heights = []
        loadDetails()
    }
    private func loadUI(_ bool: Bool){
        if bool {
            detailTableView?.refreshControl?.beginRefreshing()
        } else {
            detailTableView?.refreshControl?.endRefreshing()
        }
        commentsBtn.isHidden = bool
    }
//MARK: Buttons
    @IBAction func reloadErrorPressed(_ sender: UIButton?){
        errorTuple = (isError: false, description: nil)
        updateError(errorTuple: errorTuple)
        reload()
    }
    @IBAction func commentsBtnPressed(_ sender: UIButton) {
        if !comments.isEmpty {
            performSegue(withIdentifier: CommentViewController.identifier, sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CommentViewController {
            destinationVC.commentsGot = comments
        }
    }
//MARK: Video Player
    private func playVideo(url: URL){
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) {
            vc.player?.play()
        }
    }
//MARK: Height Calculation
    private func calculateElementHeights(cell: DetailTableViewCell) {
        let vPadding: CGFloat = 20
        let hPadding: CGFloat = 10
        
        if galleryGot.isAlbum {
            let itemCount = albumItem.images.count
            var albumConfig: ConfigTuple = (top: albumItem.title,
                                        title: nil,
                                        image: ToolBox.placeHolderImg,
                                        description: nil,
                                        bottom: albumItem.description,
                                        isBottom: false, animated: false)
            
            if itemCount == 1 {
                let item = albumItem.images[0]
                albumConfig.title = item.title
                albumConfig.description = item.description
                albumConfig.image = item.image
                albumConfig.isBottom = true
                albumConfig.animated = item.animated
                
                heights[0] = calculate(config: albumConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
            } else {
                let items = albumItem.images
                for (index,item) in items.enumerated() {
                    albumConfig.title = item.title
                    albumConfig.description = item.description
                    albumConfig.image = item.image
                    albumConfig.animated = item.animated
                    
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
                                            isBottom: true,
                                            animated: imageItem.animated)
            heights[0] = calculate(config: imageConfig, cell: cell, hPadding: hPadding, vPadding: vPadding)
        }
    }
    private func calculate(config: ConfigTuple,cell: DetailTableViewCell, hPadding: CGFloat, vPadding: CGFloat) -> CGFloat {
        let width = cell.outerFrame?.frame.width ?? 0
        
        let labelItems = Mirror.init(reflecting: config).children.map{ $0.value as? String }
        var labelsHeights: CGFloat = 0
        
        for (index,label) in labelItems.enumerated() {
            if index == 0 {
                let topFont: UIFont = .systemFont(ofSize: 22, weight: .medium)
                let rect = calculateLabelFrame(text: label, width: width, font: topFont, hPadding: hPadding, vPadding: vPadding)
                labelsHeights += rect.height
            } else {
                let otherFont: UIFont = .systemFont(ofSize: 20, weight: .light)
                let rect = calculateLabelFrame(text: label, width: width, font: otherFont, hPadding: hPadding, vPadding: vPadding)
                labelsHeights += rect.height
            }
        }
        
        let image = calculateImageRatio(config.image, frameWidth: width)
        
        var separator = cell.separatorFrame?.frame.height ?? 0
        separator = config.isBottom ? 0 : separator
        
        let result = labelsHeights + image.height + separator
        return result
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
            
            let configuration: ConfigTuple = (top: imageItem.title,
                                              title: nil,
                                              image: imageItem.image,
                                              description: nil,
                                              bottom: imageItem.description,
                                              isBottom: true,
                                              animated: imageItem.animated)
            
            cell.config(configuration)
            
        } else {
            let albumImageItem = albumItem.images[indexPath.row]
            let itemCount = albumItem.images.count
            var configuration: ConfigTuple = (top: albumItem.title,
                                              title: albumImageItem.title,
                                              image: albumImageItem.image,
                                              description:albumImageItem.description,
                                              bottom: albumItem.description,
                                              isBottom: false,
                                              animated: albumImageItem.animated)
            
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard !heights.isEmpty else {
            return 0
        }
        return heights[indexPath.row]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if galleryGot.isAlbum {
            if albumItem.images[indexPath.row].animated {
                if let mp4Link = URL(string: albumItem.images[indexPath.row].mp4!) {
                    playVideo(url: mp4Link)
                }
            }
        } else {
            if imageItem.animated {
                if let mp4Link = URL(string: imageItem.mp4!) {
                    playVideo(url: mp4Link)
                }
            }
        }
    }
}
