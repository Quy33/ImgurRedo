//
//  CommentsModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 24/11/2021.
//

import Foundation

struct Comment {
    let comment: String
    let childComments: [Comment]
    init(comment:String, childComments: [Comment]){
        self.comment = comment
        self.childComments = childComments
    }
}
