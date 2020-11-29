//
//  Clip.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 12/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit

public struct Clip: Codable {
    let clip: String?
    let preview: String?

    public enum CodingKeys: String, CodingKey {
        case clip
        case preview
    }

}
