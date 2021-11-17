//
//  DataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation

struct DataModel: Decodable {
    let data: [GalleryModel]
}
struct GalleryModel: Decodable {
    let id: String
    let title: String
    let is_album: Bool
    let link: String
    let animated: Bool?
    let mp4: String?
}
