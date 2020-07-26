//
//  GameEntity+CoreDataProperties.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 26/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//
//

import Foundation
import CoreData


extension GameEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameEntity> {
        return NSFetchRequest<GameEntity>(entityName: "GameEntity")
    }

    @NSManaged public var background: String?
    @NSManaged public var descriptionGame: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var rating: String?
    @NSManaged public var released: String?
    @NSManaged public var slug: String?
    @NSManaged public var tba: Bool
    @NSManaged public var platform_id: NSSet?

}

// MARK: Generated accessors for platform_id
extension GameEntity {

    @objc(addPlatform_idObject:)
    @NSManaged public func addToPlatform_id(_ value: PlatformGameEntity)

    @objc(removePlatform_idObject:)
    @NSManaged public func removeFromPlatform_id(_ value: PlatformGameEntity)

    @objc(addPlatform_id:)
    @NSManaged public func addToPlatform_id(_ values: NSSet)

    @objc(removePlatform_id:)
    @NSManaged public func removeFromPlatform_id(_ values: NSSet)

}
