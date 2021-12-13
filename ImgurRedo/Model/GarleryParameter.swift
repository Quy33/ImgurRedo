//
//  GalleryParameterModel.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation

class GarleryParameter {
    let section: Section
    let sort: Sort
    let page: Int
    let window: Window
    
    let showViral: (key: String, value: Bool)
    let mature: (key: String, value: Bool)
    let album_previews: (key: String, value: Bool)
    
    init(section: Section, sort: Sort, page: Int, window: Window, showViral: Bool, mature: Bool, album_previews: Bool) {
        self.section = section
        self.sort = sort
        self.page = page
        self.window = window
        
        self.showViral = (key: "showViral", value: showViral)
        self.mature = (key: "mature", value: mature)
        self.album_previews = (key: "album_previews", value: album_previews)
    }
    
    convenience init(section: Section, sort: Sort, page: Int, window: Window) {
        self.init(section: section, sort: sort, page: page, window: window, showViral: true, mature: false, album_previews: false)
    }
    
    convenience init(page: Int) {
        self.init(section: .hot, sort: .viral, page: page, window: .day)
    }
    
    convenience init() {
        self.init(page: 0)
    }
    
    enum Section: String {
        case hot = "hot"
        case top = "top"
        case user = "user"
    }
    enum Sort: String {
        case viral = "viral"
        case top = "top"
        case time = "time"
        case rising = "rising"
    }
    enum Window: String {
        case day = "day"
        case week = "week"
        case month = "month"
        case year = "year"
        case all = "all"
    }
}
