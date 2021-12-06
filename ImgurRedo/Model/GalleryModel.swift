//
//  GalleryModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import UIKit

class GalleryModel {
    final let id: String
    let title: String?
    final let isAlbum: Bool
    let link: String
    let animated: Bool
    let mp4: String?
    let type: String
    final let imagesCount: Int?
    var image: UIImage
    final let views: Int
    
    private static var thumbnailSize: ThumbnailSize = .mediumThumbnail
    private static var isThumbnail = true
    
    static func setQuality(isThumbnail: Bool, size: ThumbnailSize){
        GalleryModel.thumbnailSize = size
        GalleryModel.isThumbnail = isThumbnail
    }
    
    var url: URL {
        var urlString = ""
        if GalleryModel.isThumbnail {
            urlString = animated ? mp4! : link
            urlString = ToolBox.concatStr(string: urlString, size: GalleryModel.thumbnailSize)
        } else {
            urlString = animated ? ToolBox.concatStr(string: mp4!, size: GalleryModel.thumbnailSize) : link
        }
        guard let link = URL(string: urlString) else {
            return ToolBox.blankURL
        }
        return link
    }
    
    init(id: String, title: String?, isAlbum: Bool, link: String, animated: Bool, type: String, imagesCount: Int?, mp4: String?, image: UIImage, views: Int) {
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
        self.init(id: "", title: nil, isAlbum: false, link: "", animated: false, type: "", imagesCount: nil, mp4: nil, image: placeHolder, views: 0)
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
    //Designated init for inheritance
    init(title: String?, link: String, animated: Bool, type: String, mp4: String?, image: UIImage) {
        self.title = title
        self.link = link
        self.animated = animated
        self.type = type
        self.mp4 = mp4
        self.image = image
        self.id = ""
        self.isAlbum = false
        self.views = 0
        self.imagesCount = nil
    }
}

