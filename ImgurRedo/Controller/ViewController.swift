//
//  ViewController.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 15/11/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imgurCollectionView: UICollectionView?
    let networkManager = NetWorkManager()
    
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
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imgurCollectionView?.dequeueReusableCell(withReuseIdentifier: ImgurCollectionViewCell.identifier, for: indexPath) as! ImgurCollectionViewCell
            
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        cell.configure()
        return cell
    }
}
//MARK: CollectionView Delegate
extension ViewController: UICollectionViewDelegate {
    
}
//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 150, height: 240)
//    }
//}
//MARK: Pinterest Layout
extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
//        let random = CGFloat(arc4random_uniform(6) + 1) * 200
//        return random
        if (indexPath.item % 2) == 0 {
            return 400
        } else { return 300}
        //return 400
    }
}
