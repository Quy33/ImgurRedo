//
//  DetailTableViewCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var outerFrame: UIView?
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var topFrame: UIView!
    @IBOutlet weak var titleFrame: UIView!
    @IBOutlet weak var descriptionFrame: UIView!
    @IBOutlet weak var bottomFrame: UIView!
    
    @IBOutlet weak var SeparatorFrame: UIView!
    
    static let identifier = "DetailTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(_ configTuple: ConfigTuple) {
        cellImage.image = configTuple.image
        configLabel(label: topLabel, frame: topFrame, text: configTuple.top)
        configLabel(label: titleLabel, frame: titleFrame, text: configTuple.title)
        configLabel(label: descriptionLabel, frame: descriptionFrame, text: configTuple.description)
        configLabel(label: bottomLabel, frame: bottomFrame, text: configTuple.bottom)
    }
    
    func configLabel(label: UILabel,frame: UIView, text: String?){
        label.text = text
        if text == nil {
            label.isHidden = true
            frame.isHidden = true
        } else {
            label.isHidden = false
            frame.isHidden = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
