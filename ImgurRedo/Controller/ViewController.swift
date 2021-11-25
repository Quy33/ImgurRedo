//
//  ViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 15/11/2021.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imgurCollectionView: UICollectionView?
    @IBOutlet weak var errorFrame: UIView?
    @IBOutlet weak var errorLabel: UILabel?
    
    private let networkManager = NetWorkManager()
    private var galleries: [GalleryModel] = []
    private var pageAt = 0
    private var indexPathToMove = IndexPath(item: 0, section: 0)
    private var lowerFrameHeight: CGFloat = 0
    static var isDownloading = false
    var errorTuple: ErrorTuple = (isError: false, description: nil)
//MARK: Life Cycle function
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCell()
        imgurCollectionView?.dataSource = self
        imgurCollectionView?.delegate = self
        imgurCollectionView?.refreshControl = UIRefreshControl()
        
        imgurCollectionView?.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        setLayout(collectionView: imgurCollectionView)
        GalleryModel.setQuality(isThumbnail: false, size: .hugeThumbnail)
        errorFrame?.isHidden = true

        initialDownload()
    }

//MARK: Networking Calls
    private func initialDownload() {
        let para = GalleryParameterModel()
        ViewController.isDownloading = true
        imgurCollectionView?.refreshControl?.beginRefreshing()
        Task {
            do {
                galleries = try await performDownload(parameter: para)
                DispatchQueue.main.async {
                    self.imgurCollectionView?.refreshControl?.endRefreshing()
                    self.reset(collectionView: self.imgurCollectionView)
                    ViewController.isDownloading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    self.errorTuple = (isError: true, description: error.localizedDescription)
                    ViewController.isDownloading = false
                    self.imgurCollectionView?.refreshControl?.endRefreshing()
                    self.updateError(errorTuple: self.errorTuple)
                }
            }
        }
    }
    
    private func downloadNextPage(page: Int,indexPath: IndexPath) {
        let para = GalleryParameterModel(page: page)
        ViewController.isDownloading = true
        imgurCollectionView?.reloadItems(at: [indexPath])
        Task {
            do {
                let newGalleries = try await performDownload(parameter: para)
                galleries.append(contentsOf: newGalleries)
                DispatchQueue.main.async {
                    self.reload(collectionView: self.imgurCollectionView)
                    ViewController.isDownloading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    ViewController.isDownloading = false
                    self.errorTuple = (isError: true, description: error.localizedDescription)
                    self.imgurCollectionView?.reloadItems(at: [indexPath])
                }
            }
        }
    }
    private func performDownload(parameter: GalleryParameterModel) async throws -> [GalleryModel] {
        let dataModel = try await networkManager.requestGallery(parameter: parameter)
        let newGalleries = dataModel.data.map{ GalleryModel($0) }
        let urls = newGalleries.map{ $0.url }
        let images = try await networkManager.batchesDownload(urls: urls)
        
        for (index,gallery) in newGalleries.enumerated() {
            gallery.image = images[index]
        }
        return newGalleries
    }
    //MARK: Update CollectionView
    private func registerCell() {
        let nib = UINib(nibName: ImgurCollectionViewCell.identifier, bundle: nil)
        imgurCollectionView?.register(nib, forCellWithReuseIdentifier: ImgurCollectionViewCell.identifier)
    }
    private func setLayout(collectionView: UICollectionView?) {
        guard let collectionView = collectionView,
        collectionView == imgurCollectionView else {
            return
        }
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
    }
    private func reload(collectionView: UICollectionView?) {
        guard let collectionView = collectionView,
        collectionView == imgurCollectionView else {
            return
        }
        let contentOffset = collectionView.contentOffset
        reset(collectionView: collectionView)
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    private func reset(collectionView: UICollectionView?) {
        guard let collectionView = collectionView,
        collectionView == imgurCollectionView else {
            return
        }
        setLayout(collectionView: collectionView)
        collectionView.reloadData()
    }
    //MARK: Refresh Control
    private func updateError(errorTuple: ErrorTuple) {
        guard let imgurCollectionView = imgurCollectionView,
              let loadingFrame = errorFrame,
              let errorLabel = errorLabel
        else {
            return
        }
        errorLabel.text = errorTuple.description
        if errorTuple.isError {
            loadingFrame.isHidden = false
            imgurCollectionView.isHidden = true
        } else {
            loadingFrame.isHidden = true
            imgurCollectionView.isHidden = false
        }
    }
    @objc private func didPullToRefresh() {
        guard !ViewController.isDownloading else {
            print("Download is occuring")
            return
        }
        pageAt = 0
        galleries.removeAll()
        setLayout(collectionView: imgurCollectionView)
        imgurCollectionView?.reloadData()
        initialDownload()
    }
    //MARK: Buttons
    @IBAction func goBottomPressed(_ sender: UIButton) {
        let bottomOffSet = CGPoint(x: 0, y: imgurCollectionView!.contentSize.height - 600)
        imgurCollectionView?.setContentOffset(bottomOffSet, animated: false)
    }
    @IBAction func reloadErrorPressed(_ sender: UIButton) {
        pageAt = 0
        galleries.removeAll()
        errorTuple = (isError: false, description: nil)
        
        updateError(errorTuple: errorTuple)
        
        imgurCollectionView?.reloadData()
        initialDownload()
    }
}
//MARK: CollectionView DataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !galleries.isEmpty else {
            return 0
        }
        return galleries.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imgurCollectionView?.dequeueReusableCell(withReuseIdentifier: ImgurCollectionViewCell.identifier, for: indexPath) as! ImgurCollectionViewCell
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        guard !galleries.isEmpty else {
            return cell
        }

        if indexPath.row == galleries.count {
            cell.configure(image: ToolBox.placeHolderImg,
                           title: "Test Title",
                           count: 0,
                           views: 0,
                           type: "image/png",
                           isLast: true,
                           isLoading: ViewController.isDownloading,
                           errorTuple: errorTuple)
        } else {
            let gallery = galleries[indexPath.row]
            cell.configure(image: gallery.image,
                           title: gallery.title!,
                           count: gallery.imagesCount,
                           views: gallery.views,
                           type: gallery.type,
                           isLast: false,
                           isLoading: false,
                           errorTuple: errorTuple)
        }
        return cell
    }
}
//MARK: CollectionView Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Load more Images
        let lastCell = galleries.count
        if indexPath.row == lastCell {
            guard !ViewController.isDownloading else {
                print("Download is occuring")
                return
            }
            if !errorTuple.isError { pageAt += 1 }
            errorTuple = (isError: false, description: nil)
            let lastIndex = IndexPath(item: lastCell, section: 0)
            downloadNextPage(page: pageAt, indexPath: lastIndex)
            return
        }
        //Segue
        indexPathToMove = indexPath
        performSegue(withIdentifier: DetailViewController.identifier, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gallery = galleries[indexPathToMove.item]
        let galleryTuple = (isAlbum: gallery.isAlbum, id: gallery.id)
        
        if let destination = segue.destination as? DetailViewController {
            destination.galleryGot = galleryTuple
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImgurCollectionViewCell else {
            return
        }
        if lowerFrameHeight == 0 {
            lowerFrameHeight = cell.bottomFrame!.frame.height
            reload(collectionView: imgurCollectionView)
        }
    }
}

//MARK: Pinterest Layout
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        guard !galleries.isEmpty else {
            return 0
        }
        if indexPath.row == galleries.count {
            return 300
        }
        let gallery = galleries[indexPath.row]

        let imageFrame = calculateImageRatio(gallery.image, frameWidth: width)
                
        let titleHPadding: CGFloat = 10
        let titleVPadding: CGFloat = 20
        let font: UIFont = .systemFont(ofSize: 17)
        let titleFrame = calculateLabelFrame(text: gallery.title, width: width, font: font, hPadding: titleHPadding, vPadding: titleVPadding)

        return imageFrame.height + lowerFrameHeight + titleFrame.height
    }
}
//MARK: Extension to calculate Height
extension UIViewController {
    func calculateLabelFrame(text: String?, width: CGFloat,font: UIFont, hPadding: CGFloat, vPadding: CGFloat) -> CGRect {
        guard let string = text else {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        let horizontalPadding = hPadding * 2
        let insetWidth = width - horizontalPadding
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: insetWidth, height: CGFloat.greatestFiniteMagnitude))
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = string
        label.sizeToFit()

        let frameWithPadding = label.frame.insetBy(dx: 0, dy: -vPadding)
        
        return frameWithPadding
    }
    
    func calculateImageRatio(_ image: UIImage, frameWidth width: CGFloat) -> CGRect {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: boundingRect)
        return rect
    }
}

