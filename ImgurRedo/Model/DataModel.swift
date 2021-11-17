//
//  DataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation

struct DataModel: Decodable {
    let data: [GalleryDataModel]
}
struct GalleryDataModel: Decodable {
    let id: String
    let title: String
    let is_album: Bool
    let link: String
    let type: String?
    let animated: Bool?
    let mp4: String?
    let images_count: Int?
    let images: [GalleryDataAlbumModel]?
}
struct GalleryDataAlbumModel: Decodable {
    let link: String
    let type: String
    let animated: Bool
    let mp4: String?
}
