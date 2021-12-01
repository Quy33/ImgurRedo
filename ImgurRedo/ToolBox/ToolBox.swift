//
//  ToolBox.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import Foundation
import UIKit

class ToolBox {
    
    static let placeHolderImg: UIImage = #imageLiteral(resourceName: "placeHolder")
    static let blankURL = URL(string: "http://www.blankwebsite.com/")!
    
    func concatStr(string: String ,size: ThumbnailSize) -> String {
        var result = string
        guard let index = result.lastIndex(of: ".") else {
            return ""
        }
        result.insert(size.rawValue, at: index)
        return result
    }
    
    static func sortLinks(item: GalleryDataModel,link: inout String, animated: inout Bool, type: inout String, mp4: inout String?) {
        if item.is_album {
            let firstImage = item.images![0]
            link = firstImage.link
            animated = firstImage.animated
            type = firstImage.type
            mp4 = firstImage.mp4
        } else {
            link = item.link
            animated = item.animated!
            type = item.type!
            mp4 = item.mp4
        }
    }
    
    enum ThumbnailSize: Character {
        case smallSquare = "s"
        case bigSquare = "b"
        case smallThumbnail = "t"
        case mediumThumbnail = "m"
        case largeThumbnail = "l"
        case hugeThumbnail = "h"
    }
}
//MARK: Tuples
typealias ErrorTuple = (isError: Bool, description: String?)
typealias ConfigTuple = (top: String?, title: String?, image: UIImage, description: String?, bottom: String?, isBottom: Bool, animated: Bool)

class PaddingLabel: UILabel {
    var inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width = size.width + inset.left
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
