//
//  CommentsDataModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 24/11/2021.
//

import Foundation

class CommentDataModel: Decodable {
    let data: [CommentData]
}
class CommentData: Decodable {
    let id: Int
    let parent_id: Int
    let comment: String
    var children: [CommentData]
    let author: String
}






