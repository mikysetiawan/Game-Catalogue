//
//  PlatformGameEntity+CoreDataProperties.swift
//  
//
//  Created by Miky Setiawan on 26/07/20.
//
//

import Foundation
import CoreData

extension PlatformGameEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlatformGameEntity> {
        return NSFetchRequest<PlatformGameEntity>(entityName: "PlatformGameEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var slug: String?
    @NSManaged public var name: String?
    @NSManaged public var gameId: GameEntity?

}
