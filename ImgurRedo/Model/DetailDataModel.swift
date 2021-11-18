//
//  Detail Data Model.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import Foundation

struct DetailDataModel: Decodable {
    let data: DetailImageModel
}
struct DetailImageModel: Decodable {
    let title: String
    let description: String?
    let type: String?
    let animated: Bool?
    let link: String
    let mp4: String?
    let images: [DetailDataAlbumModel]?
}
struct DetailDataAlbumModel: Decodable {
    let title: String?
    let description: String?
    let type: String
    let animated: Bool
    let link: String
    let mp4: String?
}
