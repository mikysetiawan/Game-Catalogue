//
//  GameDetail.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 18/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit

public struct GameDetail: Codable {
    let id: Int?
    let slug: String?
    let name: String?
    let name_original: String?
    let description: String?
}
