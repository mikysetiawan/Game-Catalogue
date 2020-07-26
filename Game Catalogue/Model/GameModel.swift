//
//  GameModel.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 18/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

class GameModel {
    var id: Int?
    var slug: String?
    var name: String?
    var released: String?
    var tba: Bool?
    var background: String?
    var rating: String?
    var description: String?
    var parent_platforms: [ParentPlatform]?
    var clip: Clip?
    var short_screenshots: [ShortScreenshot]?
    
    init(id: Int, slug: String, name: String, released: String, tba: Bool, background: String, rating:String, parent_platforms: [ParentPlatform]?, clip: Clip?, short_screenshots: [ShortScreenshot]?) {
        self.id = id
        self.slug = slug
        self.name = name
        self.released = released
        self.tba = tba
        self.background = background
        self.rating = rating
        self.parent_platforms = parent_platforms
        self.clip = clip
        self.short_screenshots = short_screenshots
    }
}
