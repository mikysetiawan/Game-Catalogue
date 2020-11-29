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
    var parentPlatforms: [ParentPlatform]?
    var clip: Clip?
    var shortScreenshots: [ShortScreenshot]?

    init(
        id: Int,
        slug: String,
        name: String,
        released: String,
        tba: Bool,
        background: String,
        rating: String,
        parentPlatforms: [ParentPlatform]?,
        clip: Clip?,
        shortScreenshots: [ShortScreenshot]?) {

        self.id = id
        self.slug = slug
        self.name = name
        self.released = released
        self.tba = tba
        self.background = background
        self.rating = rating
        self.parentPlatforms = parentPlatforms
        self.clip = clip
        self.shortScreenshots = shortScreenshots
    }
}
