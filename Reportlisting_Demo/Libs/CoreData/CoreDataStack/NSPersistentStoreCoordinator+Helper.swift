//
//  NSPersistentStoreCoordinator+Helper.swift
//  Lists
//
//  Created by Suman Chatterjee on 28/05/19.
//  Copyright © 2019 Suman Chatterjee. All rights reserved.
//

import Foundation
import CoreData

public extension NSPersistentStoreCoordinator {
    
    public static var stockSQLiteStoreOptions: [AnyHashable: Any] {
        return [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSSQLitePragmasOption: ["journal_mode": "WAL"]
        ]
    }
    
    public static var stockSQLiteStoreMigrationOptions: [AnyHashable: Any] {
        return [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSSQLitePragmasOption: ["journal_mode": "DELETE"]
        ]
    }
    
    
    public class func setupSQLiteBackedCoordinator(_ managedObjectModel: NSManagedObjectModel,
                                                   storeFileURL: URL,
                                                   persistentStoreOptions: [AnyHashable : Any]? = NSPersistentStoreCoordinator.stockSQLiteStoreOptions,
                                                   completion: @escaping (CoreDataStack.CoordinatorResult) -> Void) {
        
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        backgroundQueue.async {
            do {
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                   configurationName: nil,
                                                   at: storeFileURL,
                                                   options: persistentStoreOptions)
                completion(.sucess(coordinator))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
}
