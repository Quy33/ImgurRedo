//
//  ImgurCollectionViewCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 15/11/2021.
//

import UIKit

class ImgurCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var typeFrame: UIView?
    
    static let identifier = "ImgurCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure() {
        typeFrame?.layer.cornerRadius = 20
        typeFrame?.layer.masksToBounds = true
    }
}
