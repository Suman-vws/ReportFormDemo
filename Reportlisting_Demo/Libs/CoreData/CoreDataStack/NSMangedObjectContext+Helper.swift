//
//  NSMangedObjectContext+Helper.swift
//  Lists
//
//  Created by Suman Chatterjee on 28/05/19.
//  Copyright © 2019 Suman Chatterjee. All rights reserved.
//

import Foundation
import CoreData

public typealias CoreDataStackSaveCompletionBlock = (CoreDataStack.SaveResult) -> Void

extension NSManagedObjectContext {
    
    /* Convenience method to perform save operation on "current context" as"synchronously", if changes are present. Method also ensures that save is executed on the correct thread
     Also throws error produced by save method
     */
    public func saveCurrentContextAndWait() throws -> Void {
        try  performAndWaitOrThrow(sharedSaveFlow)
    }
    
    /* Convenience method to perform save opertaion on "current context" as "asynchronously", if changes are present. Method also ensures that save operation is performed on the correct thread.
     CompletionHandler ensures execution of completion block after save operation performed.
     */
    public func saveCurrentContext(_ completionHandler: CoreDataStackSaveCompletionBlock? = nil) -> Void {
        func saveContext() -> Void {
            do {
                try sharedSaveFlow()
                completionHandler?(.sucess)
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
        perform(saveContext)
    }
    
    /* Convenience method to perform save operation on NSManagedObjectContext synchronously if changes are present.
     If any parent contexts are found, they too will be saved synchronously.
     */
    public func saveContextToStoreAndWait() throws -> Void {
        func saveContext() throws -> Void {
            try sharedSaveFlow()
            if let parentContext = parent {
                try parentContext.saveContextToStoreAndWait()
            }
        }
        try performAndWaitOrThrow(saveContext)
    }
    
    /* Convenience method to perform save operation on NSManagedObjectContext asynchronously if changes are present.
     If any parent contexts are found, they too will be saved asynchronously.
     CompletionHandler ensures execution of completion block after save operation performed.
     */
    public func saveContextToStore(_ completionHandler: CoreDataStackSaveCompletionBlock? = nil) -> Void {
        func saveContext() -> Void {
            do {
                try sharedSaveFlow()
                if let parentContext = parent {
                    parentContext.saveContextToStore(completionHandler)
                }else{
                    completionHandler?(.sucess)
                }
                
            } catch let error {
                completionHandler?(.failure(error))
            }
        }
        perform(saveContext)
    }
    
    /*Method to check if any changes in context. If haschanges then save otherwise return.
     */
    fileprivate func sharedSaveFlow() throws -> Void {
        guard hasChanges else {
            return
        }
        try save()
    }
}


//MARK:
//MARK: Async Helpers
public extension NSManagedObjectContext {
    
    public func performAndWaitOrThrow<Return>(_ body: () throws -> Return) rethrows -> Return {
        func impl(execute work: () throws -> Return, recover: (Error) throws -> Void) rethrows -> Return {
            var result: Return!
            var error: Error?
            
            typealias Fn = (() -> Void) -> Void
            let performAndWaitNoescape = self.performAndWait
            performAndWaitNoescape {
                do {
                    result = try work()
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                try recover(error)
            }
            
            return result
        }
        
        return try impl(execute: body, recover: { throw $0 })
    }
}
