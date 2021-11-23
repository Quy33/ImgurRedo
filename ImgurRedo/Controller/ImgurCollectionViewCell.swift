//
//  ImgurCollectionViewCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 15/11/2021.
//

import UIKit

class ImgurCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeFrame: UIView?
    @IBOutlet weak var cellImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var viewsLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel?
    @IBOutlet weak var bottomFrame: UIView?
    @IBOutlet weak var countFrame: UIView?
    
    @IBOutlet weak var imageFrame: UIView?
    @IBOutlet weak var titleFrame: UIView?
    @IBOutlet weak var loadingView: UIView?
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    
    
    
    static let identifier = "ImgurCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        spinner?.hidesWhenStopped = true
    }
    
    func configure(image: UIImage, title: String, count: Int?, views: Int, type: String, isLast: Bool, isLoading: Bool, isError: Bool) {
        
//        if isLast {
//            if isError {
//                spinner?.stopAnimating()
//                imageFrame?.isHidden = false
//                titleFrame?.isHidden = true
//                bottomFrame?.isHidden = true
//                loadingView?.isHidden = true
//                cellImage?.image = UIImage(systemName: "xmark")
//                typeFrame?.isHidden = true
//                return
//            } else {
//
//                imageFrame?.isHidden = false
//                titleFrame?.isHidden = false
//                bottomFrame?.isHidden = false
//                loadingView?.isHidden = true
//
//
//            }
//            if isLoading {
//                spinner?.startAnimating()
//                imageFrame?.isHidden = true
//                titleFrame?.isHidden = true
//                bottomFrame?.isHidden = true
//                loadingView?.isHidden = false
//                return
//            }
//            spinner?.stopAnimating()
//            loadingView?.isHidden = true
//            titleFrame?.isHidden = true
//            imageFrame?.isHidden = false
//            bottomFrame?.isHidden = true
//            typeFrame?.isHidden = true
//            cellImage?.image = UIImage(systemName: "plus")
//            imageFrame?.frame.size.height = 300
//            return
//        } else {
//            imageFrame?.isHidden = false
//            titleFrame?.isHidden = false
//            bottomFrame?.isHidden = false
//            loadingView?.isHidden = true
//        }
        resetCellUI(inverted: false)
        
        cellImage?.image = image
        titleLabel?.text = title
        viewsLabel?.text = "\(views)"
        
        let countString = String(count ?? 1)
        countLabel?.text = countString
        
        if count == nil || count == 1 {
            countFrame?.isHidden = true
        } else {
            countFrame?.isHidden = false
        }
        
        let typeRect = typeFrame?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        typeFrame?.layer.cornerRadius = typeRect.height / 2
        typeFrame?.layer.masksToBounds = true
        
        var isType = ""
        var isHidden = false
        
        switch type {
        case "image/gif":
            isType = "GIF"
        case "video/mp4":
            isType = "MP4"
        default :
            isType = "IMG"
            isHidden = true
        }
        typeLabel?.text = isType
        typeLabel?.adjustsFontSizeToFitWidth = true
        typeFrame?.isHidden = isHidden
        typeFrame?.layer.borderWidth = 3
        typeFrame?.layer.borderColor = UIColor.black.cgColor
        
        checkLast(isLast: isLast, isLoading: isLoading)
        checkError(isError: isError)
    }

    private func checkLast(isLast: Bool,isLoading: Bool){
        if isLast {
            //Hide Everything except for the imageFrame & replace it with a plus
        } else {
            //Unhide everything & hide the imageFrame
        }
    }
    private func checkLoading(isLoading: Bool){
        if isLoading {
            //Hide everything except for the loading frame & start animating
        } else {
            //Unhide everything & then hide the loading frame & stop animating
        }
    }
    private func checkError(isError: Bool){
        if isError {
            //Hide Everything except for the imageFrame & replace it with an X
        } else {
            //Unhide everything & hide the imageFrame
        }
    }
    private func resetCellUI(inverted: Bool){
        imageFrame?.isHidden = inverted
        titleFrame?.isHidden = inverted
        bottomFrame?.isHidden = inverted
        loadingView?.isHidden = !inverted
    }
}
