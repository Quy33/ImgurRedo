//
//  DataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation

struct RawGallery: Codable {    
    let data: [RawGalleryData]
}
struct RawGalleryData: Codable {
    let id: String
    let title: String
    let is_album: Bool
    let link: String
    let type: String?
    let animated: Bool?
    let mp4: String?
    let gifv: String?
    let images_count: Int?
    let images: [RawGalleryAlbumData]?
    let views: Int
}
struct RawGalleryAlbumData: Codable {
    let link: String
    let type: String
    let animated: Bool
    let mp4: String?
    let gifv: String?
}
