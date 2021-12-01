//
//  CommentCell.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 30/11/2021.
//

import UIKit

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    @IBOutlet weak var commentLabel: PaddingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func config(text: String) {
        commentLabel.text = text
        commentLabel.leftInset = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

