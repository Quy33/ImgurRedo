//
//  GalleryDataSource.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import UIKit

class Gallery {
    final let id: String
    let title: String?
    final let isAlbum: Bool
    let link: String
    let animated: Bool
    let mp4: String?
    let gifv: String?
    let type: String
    final let imagesCount: Int?
    var image: UIImage
    final let views: Int
    
    private static var thumbnailSize: ThumbnailSize = .mediumThumbnail
    private static var isThumbnail = true
    
    static func setQuality(isThumbnail: Bool, size: ThumbnailSize){
        Gallery.thumbnailSize = size
        Gallery.isThumbnail = isThumbnail
    }
    
    var url: URL {
        var urlString = ""
        if Gallery.isThumbnail {
            urlString = animated ? mp4! : link
            urlString = ToolBox.concatStr(string: urlString, size: Gallery.thumbnailSize)
        } else {
            urlString = animated ? ToolBox.concatStr(string: mp4!, size: Gallery.thumbnailSize) : link
        }
        guard let link = URL(string: urlString) else {
            return ToolBox.blankURL
        }
        return link
    }
    
    init(id: String, title: String?, isAlbum: Bool, link: String, animated: Bool, type: String, imagesCount: Int?, mp4: String?, image: UIImage, views: Int, gifv: String?) {
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
        self.gifv = gifv
    }

    convenience init() {
        let placeHolder = ToolBox.placeHolderImg
        self.init(id: "", title: nil, isAlbum: false, link: "", animated: false, type: "", imagesCount: nil, mp4: nil, image: placeHolder, views: 0, gifv: nil)
    }
    
    convenience init(_ item: RawGalleryData) {
        var link = ""
        var animated = false
        var type = ""
        var imagesCount: Int?
        var mp4: String?
        var gifv: String?
        var views = 0
        
        if item.is_album {
            if let firstImg = item.images?[0] {
                link = firstImg.link
                animated = firstImg.animated
                mp4 = firstImg.mp4
                gifv = firstImg.gifv
                imagesCount = item.images_count
                type = firstImg.type
            }
        } else {
            link = item.link
            animated = item.animated!
            mp4 = item.mp4
            gifv = item.gifv
            type = item.type!
        }
        views = item.views
        
        self.init(id: item.id, title: item.title, isAlbum: item.is_album, link: link, animated: animated, type: type, imagesCount: imagesCount, mp4: mp4, image: ToolBox.placeHolderImg, views: views, gifv: gifv)
    }
    //Designated init for inheritance
    init(title: String?, link: String, animated: Bool, type: String, mp4: String?, image: UIImage, gifv: String?) {
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
        self.gifv = gifv
    }
}

