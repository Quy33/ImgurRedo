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
    
    static let identifier = "ImgurCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configure(image: UIImage, title: String, count: Int?, views: Int, type: String) {
        
        let typeRect = typeLabel?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        typeFrame?.layer.cornerRadius = typeRect.height / 3
        typeFrame?.layer.masksToBounds = true
        
        
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
        typeFrame?.isHidden = isHidden
    }
}
