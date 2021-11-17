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
    let array = [#imageLiteral(resourceName: "Second"), #imageLiteral(resourceName: "First"), #imageLiteral(resourceName: "placeHolder")]

    let testTitle = "Test"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCell()
        imgurCollectionView?.dataSource = self
        imgurCollectionView?.delegate = self
        let layout = PinterestLayout()
        layout.delegate = self
        imgurCollectionView?.collectionViewLayout = layout
        
        call()
    }
//MARK: Networking Calls
    private func call() {
        let para = GalleryParameterModel()
        Task {
            do {
                let model = try await networkManager.requestGallery(parameter: para)
                
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
}
//MARK: CollectionView DataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imgurCollectionView?.dequeueReusableCell(withReuseIdentifier: ImgurCollectionViewCell.identifier, for: indexPath) as! ImgurCollectionViewCell
            
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        cell.configure(image: array[indexPath.row], title: testTitle)
        return cell
    }
}
//MARK: CollectionView Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
    }
}

//MARK: Pinterest Layout
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let image = array[indexPath.row]
        
        let lowerFrameHeight: CGFloat = 50

        let imageFrame = calculateImageRatio(image, frameWidth: width)
        let labelFrame = calculateLabelFrame(text: testTitle, font: .systemFont(ofSize: 17), width: width)
        
        return imageFrame.height + lowerFrameHeight + labelFrame.height
    }
}
//MARK: Stuff
extension UIViewController {
    func calculateLabelFrame(text: String, font: UIFont, width: CGFloat) -> CGRect {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
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
