//
//  CommentsModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 24/11/2021.
//

import Foundation
import UIKit

class Comment {
    weak var parent: Comment?
    var value: String
    let id: Int
    let parentId: Int
    var children: [Comment] = []
    var author: String
    var isCollapsed = false
    var level = 0
    var image: UIImage?
    var imageLink: URL?
    var hasImageLink: Bool = false
    var contentType: ExtensionType?
    var rawDate: Int
    var dateString: String {
        let date = NSDate(timeIntervalSince1970: Double(rawDate)) as Date
        let localDate = dateSorter(date)
        return localDate
    }
    
    init(value: String, id: Int, parentId: Int, author: String, date: Int) {
        self.value = value
        self.id = id
        self.parentId = parentId
        self.author = author
        self.rawDate = date
    }
    convenience init() {
        self.init(value: "", id: 0, parentId: 0, author: "", date: 0)
    }
    convenience init(data: CommentData) {
        self.init(value: data.comment, id: data.id, parentId: data.parent_id, author: data.author, date: data.datetime)
    }
    func add(_ child: Comment){
        children.append(child)
        child.parent = self
        child.level = self.level + 1
    }
    func dateSorter(_ date: Date) -> String {
        var dateString = "???"
        
        let formatter = DateFormatter()
        formatter.timeZone = .current
        let monthFormat = "MMMM d"
        let yearFormat = "MMMM d y"
        
        let now: Date = Date()
        let calendar = Calendar.current
        
        let same: ComparisonResult = .orderedSame
        
        let hourResult = calendar.compare(date, to: now, toGranularity: .hour)
        let dayResult = calendar.compare(date, to: now, toGranularity: .day)
        let weekResult = calendar.compare(date, to: now, toGranularity: .weekday)
        let monthResult = calendar.compare(date, to: now, toGranularity: .month)
        let yearResult = calendar.compare(date, to: now, toGranularity: .year)
        
        if yearResult != same {
            formatter.dateFormat = yearFormat
            dateString = formatter.string(from: date)
        } else if monthResult != same {
            formatter.dateFormat = monthFormat
            dateString = formatter.string(from: date)
        } else if dayResult == same {
            if let result = calendar.dateComponents([.hour], from: now, to: date).hour {
                dateString = "\(abs(result)) hour"
            }
        } else {
            if let result = calendar.dateComponents([.day], from: now, to: date).day {
                dateString = "\(abs(result)) day"
            }
        }
        
        return dateString
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
