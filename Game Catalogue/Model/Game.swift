//
//  game.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 05/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//
import UIKit

public struct Game: Codable {
    let id: Int?
    let slug: String?
    let name: String?
    let released: String?
    let tba: Bool?
    let background: String?
    let rating: String?
    let parent_platforms: [ParentPlatform]?
    let clip: Clip?
    let short_screenshots: [ShortScreenshot]?
    
    public enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case released
        case tba
        case background = "background_image"
        case rating
        case parent_platforms
        case clip
        case short_screenshots
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateString = try container.decodeIfPresent(String.self, forKey: .released)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var date: String
        if(dateString != nil){
            var dateTemp: Date
            dateTemp = dateFormatter.date(from: dateString!)!
            dateFormatter.dateFormat = "dd MMM yyyy"
            // again convert your date to string
            date = dateFormatter.string(from: dateTemp)
        }else{
            date = "01 Jan 2020"
        }
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        tba = try container.decodeIfPresent(Bool.self, forKey: .tba)
        background = try container.decodeIfPresent(String.self, forKey: .background)
        
        let ratingDouble = try container.decodeIfPresent(Double.self, forKey: .rating)
        rating = String(format:"%.2f", ratingDouble!) + "/5.00"
        
        released = date
        
        parent_platforms = try container.decodeIfPresent([ParentPlatform].self, forKey: .parent_platforms)
        
        clip = try container.decodeIfPresent(Clip.self, forKey: .clip)
        
        short_screenshots = try container.decodeIfPresent([ShortScreenshot].self, forKey: .short_screenshots)
    }
}
