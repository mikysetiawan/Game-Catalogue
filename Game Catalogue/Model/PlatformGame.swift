//
//  game.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 05/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//
import UIKit

public struct ParentPlatform: Codable {
    let platform: PlatformGame?
}

public struct PlatformGame: Codable {
    let id: Int?
    let slug: String?
    let name: String?
}