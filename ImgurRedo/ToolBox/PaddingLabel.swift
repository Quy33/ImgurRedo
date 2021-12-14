//
//  PaddingLabel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 14/12/2021.
//

import UIKit

class PaddingLabel: UILabel {
    var inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width = size.width + inset.left + inset.right
        size.height = size.height + inset.top + inset.bottom
        return size
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: inset)
        super.drawText(in: insetRect)
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: inset)
        let ctr = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        return ctr
    }
}
