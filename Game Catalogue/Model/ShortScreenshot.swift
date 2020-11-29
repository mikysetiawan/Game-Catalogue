//
//  ShortScreenshot.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 12/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit

public struct ShortScreenshot: Codable {
    let id: Int?
    let image: String?

    public enum CodingKeys: String, CodingKey {
        case id
        case image
    }

}
