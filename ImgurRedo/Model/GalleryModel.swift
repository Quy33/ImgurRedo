//
//  GalleryModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 17/11/2021.
//

import Foundation

class GalleryModel {
    let id: String
    let title: String
    let isAlbum: Bool
    let url: String
    let type: String
    let imageCount: Int
    
    init(id: String, title: String, isAlbum: Bool, link: String, type: String, imageCount: Int) {
        self.id = id
        self.title = title
        self.isAlbum = isAlbum
        self.url = link
        self.type = type
        self.imageCount = imageCount
    }
    convenience init(with item: GalleryDataModel) {
        
        let id = ""
        let title = ""
        let url = ""
        
        if item.is_album {
            
        }
        
        self.init(id: <#T##String#>, title: <#T##String#>, isAlbum: <#T##Bool#>, link: <#T##String#>, type: <#T##String#>, imageCount: <#T##Int#>)
    }
}
