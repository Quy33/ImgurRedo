//
//  ToolBox.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import Foundation
import UIKit
import CoreMedia
import AVKit

class ToolBox {
    
    static let placeHolderImg: UIImage = #imageLiteral(resourceName: "placeHolder")
    static let blankURL = URL(string: "http://www.blankwebsite.com/")!
    
    static func concatStr(string: String ,size: ThumbnailSize) -> String {
        var result = string
        guard let index = result.lastIndex(of: ".") else {
            return ""
        }
        result.insert(size.rawValue, at: index)
        return result
    }
    
    static func sortLinks(item: RawGalleryData,link: inout String, animated: inout Bool, type: inout String, mp4: inout String?) {
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
    
    static func calculateLabelFrame(text: String?, width: CGFloat,font: UIFont, hPadding: CGFloat, vPadding: CGFloat) -> CGRect {
        guard let string = text else {
            return CGRect.zero
        }
        let horizontalPadding = hPadding * 2
        let insetWidth = width - horizontalPadding
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: insetWidth, height: CGFloat.greatestFiniteMagnitude))
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = string
        label.sizeToFit()

        let frameWithPadding = label.frame.insetBy(dx: 0, dy: -vPadding)
        
        return frameWithPadding
    }
    
    static func calculateImageRatio(_ image: UIImage, frameWidth width: CGFloat) -> CGRect {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: boundingRect)
        return rect
    }
}
//MARK: Tuples
typealias ErrorTuple = (isError: Bool, description: String?)
typealias ConfigTuple = (top: String?, title: String?, image: UIImage, description: String?, bottom: String?, isBottom: Bool, animated: Bool)

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
//MARK: String Extension
extension String {
    func searchExtension() -> ExtensionType? {
        var ext: ExtensionType?
        for type in ExtensionType.allCases {
            if self.contains(type.rawValue) {
                ext = type
            }
        }
        return ext
    }
    func matchExtension() -> ExtensionType {
        var ext: ExtensionType
        switch self {
        case "image/gif":
            ext = .gif
        case "video/mp4":
            ext = .mp4
        default:
            ext = .png
        }
        return ext
    }
}
//MARK: Enums
enum ExtensionType: String, CaseIterable {
    case png = "png"
    case jpeg = "jpeg"
    case jpg = "jpg"
    case mp4 = "mp4"
    case gif = "gif"
}
enum ThumbnailSize: Character {
    case smallSquare = "s"
    case bigSquare = "b"
    case smallThumbnail = "t"
    case mediumThumbnail = "m"
    case largeThumbnail = "l"
    case hugeThumbnail = "h"
}


