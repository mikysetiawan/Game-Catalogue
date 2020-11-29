//
//  FavoriteGameProvider.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 25/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import CoreData
import UIKit

class FavoriteGameProvider {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteGame")

        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil

        return container
    }()

    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.undoManager = nil

        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }

    func getAllFavoriteGame(completion: @escaping(_ games: [GameModel]) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameEntity")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games: [GameModel] = []

                for result in results {
                    let fetchRequestPlatform = NSFetchRequest<NSManagedObject>(entityName: "PlatformGameEntity")
                    fetchRequestPlatform.predicate = NSPredicate(
                        format: "game_id == \(result.value(forKey: "id") ?? 0)"
                    )
                    do {
                        let resultPlatform = try taskContext.fetch(fetchRequestPlatform)
                        var parentPlatform: [ParentPlatform] = []
                        var clip: Clip?
                        var shortScreenshot: [ShortScreenshot] = []

                        for platform in resultPlatform {
                            let platformGame = PlatformGame(id: platform.value(forKey: "id") as? Int,
                                                            slug: platform.value(forKey: "slug") as? String,
                                                            name: platform.value(forKey: "name") as? String)

                            let tempParent = ParentPlatform(platform: platformGame)
                            parentPlatform.append(tempParent)
                        }

                        let fetchRequestClip = NSFetchRequest<NSManagedObject>(entityName: "ClipEntity")
                        fetchRequestClip.predicate = NSPredicate(
                            format: "game_id == \(result.value(forKey: "id") ?? 0)"
                        )
                        do {
                            if let resultClip = try taskContext.fetch(fetchRequestClip).first {
                                let clipTemp = Clip(
                                    clip: resultClip.value(forKey: "clip") as? String,
                                    preview: resultClip.value(forKey: "preview") as? String
                                )
                                clip = clipTemp
                            }
                        } catch let error as NSError {
                            print("Could not fetch. \(error), \(error.userInfo)")
                        }

                        let fetchRequestShortScreenshot = NSFetchRequest<NSManagedObject>(
                            entityName: "ShortScreenshotEntity"
                        )
                        fetchRequestShortScreenshot.predicate = NSPredicate(
                            format: "game_id == \(result.value(forKey: "id") ?? 0)"
                        )
                        do {
                            let resultScreenshot = try taskContext.fetch(fetchRequestShortScreenshot)
                            for screenshot in resultScreenshot {
                                let screenshotTemp = ShortScreenshot(
                                    id: screenshot.value(forKey: "id") as? Int,
                                    image: screenshot.value(forKey: "image") as? String
                                )

                                shortScreenshot.append(screenshotTemp)
                            }
                        } catch let error as NSError {
                            print("Could not fetch. \(error), \(error.userInfo)")
                        }

                        let game = GameModel(
                            id: result.value(forKey: "id") as? Int ?? 0,
                            slug: result.value(forKey: "slug") as? String ?? "",
                            name: result.value(forKey: "name") as? String ?? "",
                            released: result.value(forKey: "released") as? String ?? "",
                            tba: result.value(forKey: "tba") as? Bool ?? false,
                            background: result.value(forKey: "background") as? String ?? "",
                            rating: result.value(forKey: "rating") as? String ?? "",
                            parentPlatforms: parentPlatform,
                            clip: clip,
                            shortScreenshots: shortScreenshot
                        )

                        game.description = result.value(forKey: "descriptionGame") as? String
                        games.append(game)
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                }
                completion(games)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    func getFavoriteGame(_ id: Int, completion: @escaping(_ games: GameModel) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            do {
                if let result = try taskContext.fetch(fetchRequest).first {
                    let game = GameModel(
                        id: result.value(forKey: "id") as? Int ?? 0,
                        slug: result.value(forKey: "slug") as? String ?? "",
                        name: result.value(forKey: "name") as? String ?? "",
                        released: result.value(forKey: "released") as? String ?? "",
                        tba: result.value(forKey: "tba") as? Bool ?? false,
                        background: result.value(forKey: "background") as? String ?? "",
                        rating: result.value(forKey: "rating") as? String ?? "",
                        parentPlatforms: nil,
                        clip: nil,
                        shortScreenshots: nil
                    )

                    game.description = result.value(forKey: "descriptionGame") as? String
                    completion(game)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    func addToFavorite(gameDetail: GameModel, completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            let entity = NSEntityDescription.entity(forEntityName: "GameEntity", in: taskContext)
            let game = NSManagedObject(entity: entity!, insertInto: taskContext)

            game.setValue(gameDetail.id, forKeyPath: "id")
            game.setValue(gameDetail.slug, forKeyPath: "slug")
            game.setValue(gameDetail.name, forKeyPath: "name")
            game.setValue(gameDetail.released, forKeyPath: "released")
            game.setValue(gameDetail.tba, forKeyPath: "tba")
            game.setValue(gameDetail.background, forKeyPath: "background")
            game.setValue(gameDetail.rating, forKeyPath: "rating")
            game.setValue(gameDetail.description, forKeyPath: "descriptionGame")

            addPlatform(gameDetail: gameDetail)
            addClip(gameDetail: gameDetail)
            addScreenshot(gameDetail: gameDetail)

            do {
                try taskContext.save()
                completion()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    func addPlatform(gameDetail: GameModel) {
        let parentPlatform: [ParentPlatform] = gameDetail.parentPlatforms ?? [ParentPlatform]()

        for platform in parentPlatform {
            //1) get reference to app delegate singleton instance
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            //2) We need context from container Entity needs context to create objects
            let managedObjectContext = appDelegate.persistentContainer.viewContext

            let entityPlatform = NSEntityDescription.entity(
                forEntityName: "PlatformGameEntity",
                in: managedObjectContext
            )
            let platformObj = NSManagedObject(entity: entityPlatform!, insertInto: managedObjectContext)

            let childPlatform = platform.platform
            platformObj.setValue(childPlatform?.id, forKeyPath: "id")
            platformObj.setValue(childPlatform?.slug, forKeyPath: "slug")
            platformObj.setValue(childPlatform?.name, forKeyPath: "name")
            platformObj.setValue(gameDetail.id, forKeyPath: "game_id")

            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    func addClip(gameDetail: GameModel) {
        var clip: Clip?
        //1) get reference to app delegate singleton instance
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        //2) We need context from container Entity needs context to create objects
        let managedObjectContext = appDelegate.persistentContainer.viewContext

        let entityPlatform = NSEntityDescription.entity(forEntityName: "ClipEntity", in: managedObjectContext)
        let platformObj = NSManagedObject(entity: entityPlatform!, insertInto: managedObjectContext)

        clip = gameDetail.clip
        if clip?.clip != nil {
            platformObj.setValue(clip?.clip, forKeyPath: "clip")
            platformObj.setValue(clip?.preview, forKeyPath: "preview")
            platformObj.setValue(gameDetail.id, forKeyPath: "game_id")
        }

        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func addScreenshot(gameDetail: GameModel) {
        let shortScreenshot: [ShortScreenshot] = gameDetail.shortScreenshots ?? [ShortScreenshot]()

        for screenshot in shortScreenshot {
            //1) get reference to app delegate singleton instance
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            //2) We need context from container Entity needs context to create objects
            let managedObjectContext = appDelegate.persistentContainer.viewContext

            let entityPlatform = NSEntityDescription.entity(
                forEntityName: "ShortScreenshotEntity", in: managedObjectContext
            )
            let platformObj = NSManagedObject(entity: entityPlatform!, insertInto: managedObjectContext)

            platformObj.setValue(screenshot.id, forKeyPath: "id")
            platformObj.setValue(screenshot.image, forKeyPath: "image")
            platformObj.setValue(gameDetail.id, forKeyPath: "game_id")

            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    func removeAllFavorite(completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameEntity")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
                batchDeleteResult.result != nil {
                completion()
            }
        }
    }

    func removeFavorite(_ id: Int, completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            var success = false
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameEntity")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
                batchDeleteResult.result != nil {
                success = true
            } else {
                success = false
            }

            let fetchRequestPlatform = NSFetchRequest<NSFetchRequestResult>(entityName: "PlatformGameEntity")
            fetchRequestPlatform.predicate = NSPredicate(format: "game_id == \(id)")
            let batchDeleteRequestPlatform = NSBatchDeleteRequest(fetchRequest: fetchRequestPlatform)
            batchDeleteRequestPlatform.resultType = .resultTypeCount
            if let batchDeleteResultPlatform = try?
                taskContext.execute(batchDeleteRequestPlatform) as? NSBatchDeleteResult,
                batchDeleteResultPlatform.result != nil {
                success = true
            } else {
                success = false
            }

            let fetchRequestClip = NSFetchRequest<NSFetchRequestResult>(entityName: "ClipEntity")
            fetchRequestClip.predicate = NSPredicate(format: "game_id == \(id)")
            let batchDeleteRequestClip = NSBatchDeleteRequest(fetchRequest: fetchRequestClip)
            batchDeleteRequestClip.resultType = .resultTypeCount
            if let batchDeleteResultClip = try? taskContext.execute(batchDeleteRequestClip) as? NSBatchDeleteResult,
                batchDeleteResultClip.result != nil {
                success = true
            } else {
                success = false
            }

            let fetchRequestScreenshot = NSFetchRequest<NSFetchRequestResult>(entityName: "ShortScreenshotEntity")
            fetchRequestScreenshot.predicate = NSPredicate(format: "game_id == \(id)")
            let batchDeleteRequestScreenshot = NSBatchDeleteRequest(fetchRequest: fetchRequestScreenshot)
            batchDeleteRequestScreenshot.resultType = .resultTypeCount
            if let batchDeleteResultScreenshot = try?
                taskContext.execute(batchDeleteRequestScreenshot) as? NSBatchDeleteResult,
                batchDeleteResultScreenshot.result != nil {
                success = true
            } else {
                success = false
            }

            if success {
                completion()
            }
        }
    }
}
