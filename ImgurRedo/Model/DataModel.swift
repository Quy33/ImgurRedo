//
//  DataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation

struct DataModel: Codable {
    let data: [GalleryDataModel]
}
struct GalleryDataModel: Codable {
    let id: String
    let title: String
    let is_album: Bool
    let link: String
    let type: String?
    let animated: Bool?
    let mp4: String?
    let images_count: Int?
    let images: [GalleryDataAlbumModel]?
    let views: Int
}
struct GalleryDataAlbumModel: Codable {
    let link: String
    let type: String
    let animated: Bool
    let mp4: String?
}
