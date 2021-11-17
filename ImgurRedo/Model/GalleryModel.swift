//
//  GalleryModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import Foundation
import UIKit

class GalleryModel: ToolBox {
    let id: String
    let title: String
    let isAlbum: Bool
    let link: String
    let animated: Bool
    let mp4: String?
    let type: String
    let imagesCount: Int?
    var image: UIImage
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
    
    init(id: String, title: String, isAlbum: Bool, link: String, animated: Bool, type: String, imagesCount: Int?, mp4: String?, image: UIImage) {
        self.id = id
        self.title = title
        self.isAlbum = isAlbum
        self.link = link
        self.animated = animated
        self.type = type
        self.imagesCount = imagesCount
        self.mp4 = mp4
        self.image = image
    }

    convenience override init() {
        let placeHolder = ToolBox.placeHolderImg
        self.init(id: "", title: "", isAlbum: false, link: "", animated: false, type: "", imagesCount: nil, mp4: nil, image: placeHolder)
    }
    convenience init(_ item: GalleryDataModel) {
        var newLink = ""
        var newAnimated = false
        var newType = ""
        var newImagesCount: Int?
        var newMp4: String?
        
        ToolBox.sortLinks(item: item, link: &newLink, animated: &newAnimated, type: &newType, mp4: &newMp4)
        
        newImagesCount = item.is_album ? item.images_count! : nil
        
        self.init(id: item.id, title: item.title, isAlbum: item.is_album, link: newLink, animated: newAnimated, type: newType, imagesCount: newImagesCount, mp4: newMp4, image: ToolBox.placeHolderImg)
    }
}

