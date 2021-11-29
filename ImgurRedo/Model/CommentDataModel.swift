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
}
extension CommentData {
    func forEachDepthFirst(_ visit: (CommentData)->Void ) {
        visit(self)
        self.children.forEach {
            $0.forEachDepthFirst(visit)
        }
    }
}
class Comment {
    weak var parent: Comment?
    var value: String
    let id: Int
    let parentId: Int
    var children: [Comment] = []
    init(value: String, id: Int, parentId: Int) {
        self.value = value
        self.id = id
        self.parentId = parentId
    }
    func add(_ child: Comment){
        children.append(child)
        child.parent = self
    }
}



