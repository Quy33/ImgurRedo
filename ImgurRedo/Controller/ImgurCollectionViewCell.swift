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
        loadingView?.isHidden = true
    }
    func configure(image: UIImage, title: String, count: Int?, views: Int, type: String, isLast: Bool, isLoading: Bool, isError: Bool) {
        
        if !isLast {
            resetCellUI(boolean: false)
            
            cellImage?.image = image
            titleLabel?.text = title
            viewsLabel?.text = "\(views)"
            
            countFrameConfig(count: count)
            typeFrameConfig(type: type)
        } else {
            configLastCell(isLoading: isLoading, isError: isError)
        }
    }
    //MARK: Configuring the cell behaviour when downloading & getting error
    private func configLastCell(isLoading: Bool, isError: Bool){
        //Hide Everything except for the imageFrame & replace it with a plus
        if isLoading {
            spinner?.startAnimating()
            resetCellUI(boolean: true)
        } else {
            spinner?.stopAnimating()
            if isError {
                configImage(imageName: "xmark")
            } else {
                configImage(imageName: "plus")
            }
        }
    }
    private func resetCellUI(boolean: Bool){
        imageFrame?.isHidden = boolean
        titleFrame?.isHidden = boolean
        bottomFrame?.isHidden = boolean
        loadingView?.isHidden = !boolean
    }
    private func configImage(imageName: String) {
        loadingView?.isHidden = true
        titleFrame?.isHidden = true
        bottomFrame?.isHidden = true
        typeFrame?.isHidden = true
            
        imageFrame?.isHidden = false
        cellImage?.image = UIImage(systemName: imageName)
        imageFrame?.frame.size.height = 300
    }
    //MARK: Config The elements inside the cell
    private func typeFrameConfig(type: String) {
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
    }
    private func countFrameConfig(count: Int?){
        countLabel?.text = String(count ?? 1)
        
        if count == nil || count == 1 {
            countFrame?.isHidden = true
        } else {
            countFrame?.isHidden = false
        }
    }
}

