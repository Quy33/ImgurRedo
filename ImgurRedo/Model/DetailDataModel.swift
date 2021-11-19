//
//  Detail Data Model.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import Foundation

struct DetailDataModel: Codable {
    let data: DetailImageModel
}
struct DetailImageModel: Codable {
    let title: String
    let description: String?
    let type: String?
    let animated: Bool?
    let link: String
    let mp4: String?
    let images: [DetailDataAlbumModel]?
}
struct DetailDataAlbumModel: Codable {
    let title: String?
    let description: String?
    let type: String
    let animated: Bool
    let link: String
    let mp4: String?
}
