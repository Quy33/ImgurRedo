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
    
    static func calculateMediaRatio(_ size: CGSize, frameWidth width: CGFloat) -> CGRect {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: size, insideRect: boundingRect)
        return rect
    }
}
//MARK: Tuples
typealias ErrorTuple = (isError: Bool, description: String?)
typealias ConfigTuple = (top: String?, title: String?, image: UIImage, description: String?, bottom: String?, isBottom: Bool, animated: Bool)
typealias GalleryTuple = (isAlBum: Bool, id: String)
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
    case gifv = "gifv"
}
enum ThumbnailSize: Character {
    case smallSquare = "s"
    case bigSquare = "b"
    case smallThumbnail = "t"
    case mediumThumbnail = "m"
    case largeThumbnail = "l"
    case hugeThumbnail = "h"
}
//MARK: Image Extension
extension UIImage {
    func drawImage(toWidth w: CGFloat) -> UIImage {
        let calculatedSize = ToolBox.calculateMediaRatio(self.size, frameWidth: w).size
        
        let rect = CGRect(origin: self.accessibilityFrame.origin, size: calculatedSize)
        
        let renderer = UIGraphicsImageRenderer(size: calculatedSize)
        let resizedImage = renderer.image { context in
            UIColor.black.setFill()
            context.fill(rect)
            self.draw(in: rect)
        }
        
        return resizedImage
    }
    func drawBlankThumbnail(withWidth w: CGFloat,color: UIColor = .black) -> UIImage {
        let calculatedSize = ToolBox.calculateMediaRatio(self.size, frameWidth: w).size
        let rect = CGRect(origin: .zero, size: calculatedSize)
        
        let renderer = UIGraphicsImageRenderer(size: calculatedSize)
        let image = UIImage()
        let blankThumbnail = renderer.image { context in
            color.setFill()
            context.fill(rect)
            image.draw(in: rect)
        }
        return blankThumbnail
    }
}

