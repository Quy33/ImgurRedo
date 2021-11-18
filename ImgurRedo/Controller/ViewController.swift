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
    let networkManager = NetWorkManager()
    var galleries: [GalleryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCell()
        imgurCollectionView?.dataSource = self
        imgurCollectionView?.delegate = self
        setLayout(collectionView: imgurCollectionView)
                
        call()
    }
//MARK: Networking Calls
    private func call() {
        let para = GalleryParameterModel()
        Task {
            do {
                let dataModel = try await networkManager.requestGallery(parameter: para)
                galleries = dataModel.data.map{ GalleryModel($0) }
                GalleryModel.thumbnailSize = .smallThumbnail
                //galleryModel.forEach{ print($0.url) }
                let urls = galleries.map{ $0.url }
                let images = try await networkManager.batchesDownload(urls: urls)
                
                for (index,gallery) in galleries.enumerated() {
                    gallery.image = images[index]
                }
                
                DispatchQueue.main.async {
                    self.imgurCollectionView?.reloadData()
                    self.setLayout(collectionView: self.imgurCollectionView)
                }
                
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
//MARK: Buttons
    @IBAction func testPressed(_ sender: UIButton) {
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
        
        cell.configure(image: galleries[indexPath.row].image, title: galleries[indexPath.row].title)
        return cell
    }
}
//MARK: CollectionView Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImgurCollectionViewCell
        print(cell.titleLabel?.frame.height)
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
        let titleWidth = width - (titleHPadding * 2)
        
        let titleFrame = calculateLabelFrame(text: gallery.title, font: .systemFont(ofSize: 17), width: titleWidth)
        let titleHeight = titleFrame.height + (titleVPadding * 2)
        
        return imageFrame.height + lowerFrameHeight + titleHeight
    }
}
//MARK: Stuff
extension UIViewController {
    func calculateLabelFrame(text: String, font: UIFont, width: CGFloat) -> CGRect {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame
    }
    func calculateImageRatio(_ image: UIImage, frameWidth width: CGFloat) -> CGRect {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: boundingRect)
        return rect
    }
}
