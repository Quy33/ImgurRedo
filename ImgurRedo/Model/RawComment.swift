//
//  CommentsDataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 24/11/2021.
//

import Foundation

class RawComment: Decodable {
    let data: [RawCommentData]
}
class RawCommentData: Decodable {
    let id: Int
    let parent_id: Int
    let comment: String
    var children: [RawCommentData]
    let author: String
    let datetime: Int
}






