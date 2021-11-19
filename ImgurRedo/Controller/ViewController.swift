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
    private let networkManager = NetWorkManager()
    private var galleries: [GalleryModel] = []
    private var pageAt = 0
    private var indexPathToMove = IndexPath(item: 0, section: 0)
    static var isDownloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCell()
        imgurCollectionView?.dataSource = self
        imgurCollectionView?.delegate = self
        GalleryModel.gallerySize = .hugeThumbnail
        setLayout(collectionView: imgurCollectionView)                
        initialDownload()
    }
//MARK: Networking Calls
    private func initialDownload() {
        let para = GalleryParameterModel()
        
        guard !ViewController.isDownloading else {
            print("Download is occuring")
            return
        }
        print("Begin download")
        ViewController.isDownloading = true
        Task {
            do {
                galleries = try await performDownload(parameter: para)
                
                DispatchQueue.main.async {
                    self.reset(collectionView: self.imgurCollectionView)
                }
                print("Finished Download")
                ViewController.isDownloading = false
            } catch {
                print("Error: \(error)")
            }
        }
    }
    private func downloadNextPage(page: Int) {
        
        guard !ViewController.isDownloading else {
            print("Download is occuring")
            return
        }
        
        let para = GalleryParameterModel(page: page)
        print("Begin adding more")
        ViewController.isDownloading = true
        Task {
            do {
                
                let newGalleries = try await performDownload(parameter: para)
                
                galleries.append(contentsOf: newGalleries)
                
                DispatchQueue.main.async {
                    self.reload(collectionView: self.imgurCollectionView)
                }
                print("Finished adding more")
                ViewController.isDownloading = false
            } catch {
                print("Error: \(error)")
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
    
//MARK: Buttons
    @IBAction func addPressed(_ sender: UIButton) {
        pageAt += 1
        downloadNextPage(page: pageAt)
    }
    @IBAction func reloadPressed(_ sender: UIButton) {
        guard !ViewController.isDownloading else {
            print("Download is occuring")
            return
        }
        pageAt = 0
        galleries = []
        imgurCollectionView?.reloadData()
        initialDownload()
    }
    //MARK: Small Functions
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
    private func reset(collectionView: UICollectionView?) {
        guard let collectionView = collectionView,
        collectionView == imgurCollectionView else {
            return
        }
        collectionView.reloadData()
        setLayout(collectionView: collectionView)
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
}
//MARK: CollectionView DataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !galleries.isEmpty else {
            return 0
        }
        return galleries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imgurCollectionView?.dequeueReusableCell(withReuseIdentifier: ImgurCollectionViewCell.identifier, for: indexPath) as! ImgurCollectionViewCell
        
        guard !galleries.isEmpty else {
            return cell
        }
            
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        let gallery = galleries[indexPath.row]
                
        cell.configure(image: gallery.image, title: gallery.title!, count: gallery.imagesCount, views: gallery.views, type: gallery.type)
        
        return cell
    }
}
//MARK: CollectionView Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
}

//MARK: Pinterest Layout
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        guard !galleries.isEmpty else {
            return 0
        }
        let gallery = galleries[indexPath.row]
        
        let lowerFrameHeight: CGFloat = 50

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

