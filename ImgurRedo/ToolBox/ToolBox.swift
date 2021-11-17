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
    
    func concatStr(string: String ,size: ThumbnailSize) -> String {
        var result = string
        guard let index = result.lastIndex(of: ".") else {
            return ""
        }
        result.insert(size.rawValue, at: index)
        return result
    }
    
    func sortType(link: String, animated: Bool, mp4: String?) -> String {
        let urlString = animated ? mp4! : link
        return urlString
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
//URL(string: "http://www.blankwebsite.com/")!
