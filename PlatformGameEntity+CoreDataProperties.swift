//
//  PlatformGameEntity+CoreDataProperties.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 26/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//
//

import Foundation
import CoreData


extension PlatformGameEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlatformGameEntity> {
        return NSFetchRequest<PlatformGameEntity>(entityName: "PlatformGameEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var slug: String?
    @NSManaged public var game_id: GameEntity?

}
