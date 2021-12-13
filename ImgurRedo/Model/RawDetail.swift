//
//  Detail Data Model.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 18/11/2021.
//

import Foundation

struct RawDetail: Codable {
    let data: RawImageData
}
struct RawImageData: Codable {
    let title: String
    let description: String?
    let type: String?
    let animated: Bool?
    let link: String
    let mp4: String?
    let images: [RawAlbumData]?
}
struct RawAlbumData: Codable {
    let title: String?
    let description: String?
    let type: String
    let animated: Bool
    let link: String
    let mp4: String?
}
