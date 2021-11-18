//
//  GalleryModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import Foundation
import UIKit

class GalleryModel {
    let id: String
    let title: String
    let isAlbum: Bool
    let link: String
    let animated: Bool
    let mp4: String?
    let type: String
    let imagesCount: Int?
    var image: UIImage
    let views: Int
    
    static var thumbnailSize: ToolBox.ThumbnailSize = .mediumThumbnail
    
    var url: URL {
        var urlString = animated ? mp4! : link
        urlString = ToolBox.concatStr(string: urlString, size: GalleryModel.thumbnailSize)
        
        guard let link = URL(string: urlString) else {
            return ToolBox.blankURL
        }
        return link
    }
    
    init(id: String, title: String, isAlbum: Bool, link: String, animated: Bool, type: String, imagesCount: Int?, mp4: String?, image: UIImage, views: Int) {
        self.id = id
        self.title = title
        self.isAlbum = isAlbum
        self.link = link
        self.animated = animated
        self.type = type
        self.imagesCount = imagesCount
        self.mp4 = mp4
        self.image = image
        self.views = views
    }

    convenience init() {
        let placeHolder = ToolBox.placeHolderImg
        self.init(id: "", title: "", isAlbum: false, link: "", animated: false, type: "", imagesCount: nil, mp4: nil, image: placeHolder, views: 0)
    }
    convenience init(_ item: GalleryDataModel) {
        var newLink = ""
        var newAnimated = false
        var newType = ""
        var newImagesCount: Int?
        var newMp4: String?
        var newViews: Int
        
        ToolBox.sortLinks(item: item, link: &newLink, animated: &newAnimated, type: &newType, mp4: &newMp4)
        
        newImagesCount = item.is_album ? item.images_count! : nil
        newViews = item.views
        
        self.init(id: item.id, title: item.title, isAlbum: item.is_album, link: newLink, animated: newAnimated, type: newType, imagesCount: newImagesCount, mp4: newMp4, image: ToolBox.placeHolderImg, views: newViews)
    }
}

