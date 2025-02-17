//
//  Persistence.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 17.05.2023.
//

import CoreData


func MOC() -> NSManagedObjectContext {
    return PersistenceController.shared.container.viewContext
}

func SAVE(context: NSManagedObjectContext) {
    do {
        try context.save()
    } catch {
        fatalError("Unresolved error \(error)")
    }
}

func SAVE() { SAVE(context: MOC()) }

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "IZA_xhomol29_PROJ")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
