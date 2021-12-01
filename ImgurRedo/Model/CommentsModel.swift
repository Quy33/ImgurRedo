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
    var level = 1
    init(value: String, id: Int, parentId: Int) {
        self.value = value
        self.id = id
        self.parentId = parentId
    }
    convenience init() {
        self.init(value: "", id: 0, parentId: 0)
    }
    convenience init(data: CommentData) {
        self.init(value: data.comment, id: data.id, parentId: data.parent_id)
    }
    func add(_ child: Comment){
        children.append(child)
        child.parent = self
        child.level = self.level + 1
    }
}
extension Comment {
    func forEachDepthFirst(_ visit: (Comment)->Void ) {
        visit(self)
        self.children.forEach {
            $0.forEachDepthFirst(visit)
        }
    }
    func traverse(container: inout [Comment],selected: Comment,_ visit: (Comment,Comment,inout [Comment])->Void){
        visit(self,selected, &container)
        self.children.forEach{
            $0.traverse(container: &container, selected: selected, visit)
        }
    }
}
