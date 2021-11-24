//
//  DetailModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import UIKit

class DetailModel: GalleryModel {
    let description: String?

    init(title: String?, link: String, animated: Bool, type: String, mp4: String?, image: UIImage, description: String?) {
        self.description = description
        super.init(title: title, link: link, animated: animated, type: type, mp4: mp4, image: image)
    }
    convenience init() {
        self.init(title: nil, link: "", animated: false, type: "", mp4: nil, image: ToolBox.placeHolderImg, description: nil)
    }
    convenience init(_ model: DetailImageModel) {
        self.init(title: model.title, link: model.link, animated: model.animated!, type: model.type!, mp4: model.mp4, image: ToolBox.placeHolderImg, description: model.description)
    }
}
class DetailAlbumModel {
    let title: String?
    let description: String?
    var images: [DetailModel]
    let link: String
    init(title: String?, description: String?, images: [DetailModel], link: String) {
        self.title = title
        self.description = description
        self.images = images
        self.link = link
    }
    convenience init() {
        self.init(title: nil, description: nil, images: [], link: "")
    }
    convenience init(_ model: DetailImageModel) {
        let albumImages = model.images!
        var images: [DetailModel] = []
        for image in albumImages {
            let newImage = DetailModel(title: image.title, link: image.link, animated: image.animated, type: image.type, mp4: image.mp4, image: ToolBox.placeHolderImg, description: image.description)
            images.append(newImage)
        }

        self.init(title: model.title, description: model.description, images: images, link: model.link)
    }
}
