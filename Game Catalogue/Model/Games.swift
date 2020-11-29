//
//  Games.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 05/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

public struct Games: Codable {
    let count: Int?
    let next: String?
    let prev: String?
    let game: [Game]?

       enum CodingKeys: String, CodingKey {
           case count
           case next = "next"
           case prev = "previous"
           case game = "results"
       }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        next = try container.decodeIfPresent(String.self, forKey: .next)
        prev = try container.decodeIfPresent(String.self, forKey: .prev)
        game = try container.decodeIfPresent([Game].self, forKey: .game)
    }
}
