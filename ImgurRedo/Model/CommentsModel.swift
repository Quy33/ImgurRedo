//
//  CommentsModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 24/11/2021.
//

import Foundation

class Comment {
    weak var parent: Comment?
    var value: String
    let id: Int
    let parentId: Int
    var children: [Comment] = []
    var isCollapsed = false
    init(value: String, id: Int, parentId: Int) {
        self.value = value
        self.id = id
        self.parentId = parentId
    }
    convenience init() {
        self.init(value: "", id: 0, parentId: 0)
    }
    func add(_ child: Comment){
        children.append(child)
        child.parent = self
    }
}
extension Comment {
    func forEachDepthFirst(_ visit: (Comment)->Void ) {
        visit(self)
        self.children.forEach {
            $0.forEachDepthFirst(visit)
        }
    }
}
