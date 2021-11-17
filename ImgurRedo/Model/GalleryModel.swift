//
//  GalleryModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import Foundation

class GalleryModel: ToolBox {
    let id: String
    let title: String
    let isAlbum: Bool
    let link: String
    let animated: Bool
    let mp4: String?
    let type: String
    let imagesCount: Int?
    static var thumbnailSize: ThumbnailSize = .mediumThumbnail
    
    var url: URL {
        var urlString = sortType(link: link, animated: animated, mp4: mp4)
        urlString = concatStr(string: urlString, size: GalleryModel.thumbnailSize)
        
        guard let link = URL(string: urlString) else {
            let none = URL(string: "http://www.blankwebsite.com/")!
            return none
        }
        return link
    }
    
    init(id: String, title: String, isAlbum: Bool, link: String, animated: Bool, type: String, imagesCount: Int?, mp4: String?) {
        self.id = id
        self.title = title
        self.isAlbum = isAlbum
        self.link = link
        self.animated = animated
        self.type = type
        self.imagesCount = imagesCount
        self.mp4 = mp4
    }
    convenience override init() {
        self.init(id: "", title: "", isAlbum: false, link: "", animated: false, type: "", imagesCount: nil, mp4: nil)
    }
    convenience init(_ item: GalleryDataModel) {
        var link = ""
        var animated = false
        var type = ""
        var imagesCount: Int?
        var mp4: String?
        
        if item.is_album {
            let firstImage = item.images![0]
            link = firstImage.link
            animated = firstImage.animated
            type = firstImage.type
            imagesCount = item.images_count
            mp4 = firstImage.mp4
        } else {
            link = item.link
            animated = item.animated!
            type = item.type!
            mp4 = item.mp4
        }
        
        self.init(id: item.id, title: item.title, isAlbum: item.is_album, link: link, animated: animated, type: type, imagesCount: imagesCount, mp4: mp4)
    }
}

class ToolBox {
    
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
