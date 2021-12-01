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
    func config(_ comment: Comment) {
        let counter = comment.level <= 5 ? comment.level : 5
        commentLabel.inset = UIEdgeInsets(top: 0, left: 20 * CGFloat(counter), bottom: 0, right: 0)
        commentLabel.text = comment.value
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

