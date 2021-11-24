//
//  CommentsDataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 24/11/2021.
//

import Foundation

struct CommentsDataModel: Decodable {
    let data: [CommentsData]
}
struct CommentsData: Decodable {
    let comment: String
    let children: [CommentsDataModel]
}
