//
//  CoreDataManager.swift
//  Lists
//
//  Created by Suman Chatterjee on 28/05/19.
//  Copyright © 2019 Suman Chatterjee. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    //MARK:  - - - - - - - Properties - - - - - - -
    public var dataStack: CoreDataStack!
    static let sharedStore =  { () -> CoreDataManager in
        
        let instance = CoreDataManager()
        return instance
    }()
    
    
    /*
    private init(){
        
        CoreDataStack.createSQLiteStore(storeName: "ReporDemo") { [unowned self] result in
            switch result {
            case .sucess(let stack):
                self.dataStack = stack
                print("Data Stack Setup Successful")
            case .failure(let error):
                assertionFailure("\(error)")
            }
        }
    }   */

    //MARK:--------Fetch Entities------------//
    
    func fetchEntities(_ entityClass : AnyClass , predicate : NSPredicate? = nil , sortDescriptors : [NSSortDescriptor]? = nil , inContext : NSManagedObjectContext? = nil) -> NSArray? {
        
        let    context : NSManagedObjectContext = inContext ?? dataStack.mainMOC
        let fetchRequest: NSFetchRequest = self.fetchRequest(forEntity: entityClass)
        
        if  let   assignPredicate = predicate{
            
            fetchRequest.predicate = assignPredicate
        }
        
        if  let   descriptors = sortDescriptors{
            
            fetchRequest.sortDescriptors = descriptors
        }
        
        var result:NSArray?
        do {
            result = try context.fetch(fetchRequest) as NSArray?
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return result!
        
    }
    
    //    MARK:- Universal delete method
    /// Author: Suman
    /// Universal delete method
    ///
    /// - Parameters:
    ///   - targetEntity: Name of the Entity
    ///   - predicate: Predicate (Optional)
    ///   - inContext: NSManagedObjectContext (Optional)
    func deleteFrom(_ targetEntity: AnyClass, predicate: NSPredicate? = nil, inContext: NSManagedObjectContext? = nil) {
        
        let deleteContext : NSManagedObjectContext = inContext ?? dataStack.mainMOC
        let fetchRequest: NSFetchRequest = self.fetchRequest(forEntity: targetEntity)
        
        if  let   assignPredicate = predicate {
            fetchRequest.predicate = assignPredicate
        }
        
        let result = try! deleteContext.fetch(fetchRequest) as NSArray?
        if (result?.count)! > 0 {
            for item in result! {
                deleteContext.delete(item as! NSManagedObject)
            }
        } else {
            //...
        }
    }
    
    
    
    //MARK: // ----------Save Data on Context--------------//
    func  saveOrFailOnContext(_ context: NSManagedObjectContext? = nil,  closure : @escaping ( _ customeContext : NSManagedObjectContext) -> Void) -> Void {
        
        let  privateContext : NSManagedObjectContext = context ?? dataStack.newChildMOC()
        privateContext.perform {
            
            closure(privateContext)
            
        }
        
    }
    
    //MARK: // ----------Save and Wait Data on Context--------------//
    
    func  saveOrFailAndWaitOnContext(_ context: NSManagedObjectContext? = nil,  closure : @escaping ( _ customeContext : NSManagedObjectContext) -> Void) -> Void {
        
        let  privateContext : NSManagedObjectContext = context ?? dataStack.newChildMOC()
        privateContext.performAndWait {
            
            closure(privateContext)
            
        }
        
    }
    
    //MARK: // -----------Private context-------//
    func  fetchPrivateContext() -> NSManagedObjectContext{
        
        return  dataStack.newChildMOC()
        
    }
    //MARK: // -----------Main context-------//
    func  fetchMainContext() -> NSManagedObjectContext{
        
        return  dataStack.mainMOC
        
    }
    //MARK: // ------------Save used context to main context------//
    func  saveCurrentContext(_ context : NSManagedObjectContext) -> Void {
        
        context.saveContextToStore()
        
    }
    
    //MARK: // ------------Save used context to main context on Block------//
    func  saveCurrentContextOnBlock(_ context : NSManagedObjectContext,onSuccess : ((_ status : Bool) -> Void)? = nil) -> Void {
        
        context.saveContextToStore{ _   in
            
            if let _ = onSuccess{
                
                onSuccess!(true)
            }
        }
        
    }
    
    
    //MARK: // -----------  Delete Duplicate DBObjects -------//
    func deleteDuplicateDBObjects(entityName: String, primaryKey : String , argMainQuery: NSPredicate? = nil, propertiesToGroupBy:[String], manageObjContext: NSManagedObjectContext?) {
        
        let  _manageObjContext : NSManagedObjectContext =  manageObjContext ?? dataStack.mainMOC
        
        let countExpr = NSExpressionDescription()
        countExpr.name = "count"
        countExpr.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: primaryKey)])
        countExpr.expressionResultType = .objectIDAttributeType
        
        //► Subquery
        let productsToKeepRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        productsToKeepRequest.resultType = .dictionaryResultType
        productsToKeepRequest.propertiesToGroupBy = propertiesToGroupBy
        productsToKeepRequest.propertiesToFetch = [primaryKey, countExpr ]
        productsToKeepRequest.havingPredicate = NSPredicate(format: "%@ > 1", NSExpression(forVariable: "count"))
        
        let results = try! _manageObjContext.fetch(productsToKeepRequest)
        let uniqueIds = results.map {(arg)-> NSNumber? in
            if let dic = arg as? [String: Any], let value = dic[primaryKey] {
                return value as? NSNumber
            }
            return NSNumber(value: 0)
        }
        
        //► Main query
        let duplicatesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let mainQuery = NSPredicate(format:"\(primaryKey) IN %@", uniqueIds)
        if let query = argMainQuery {
            let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [mainQuery, query])
            duplicatesRequest.predicate = andPredicate
        } else {
            duplicatesRequest.predicate = mainQuery
        }
        let duplicatesBatchRequest = NSBatchDeleteRequest(fetchRequest: duplicatesRequest)
        duplicatesBatchRequest.resultType = .resultTypeCount
        let duplicateObjects = try! _manageObjContext.execute(duplicatesBatchRequest) as! NSBatchDeleteResult
        let deletedObjectsCount = duplicateObjects.result as! Int
        print("Deleted duplicate objects count: \(deletedObjectsCount)")
    }
    
    
    
    //MARK: // ----------Fetch manageObject For Entity with NSSortDescriptor,fetchLimit,propertiesToFetch -------------//
    
    func fetchManageObjectsForEnity(enityName : NSString, predicate : NSPredicate, fetchLimit : Int,  fetchOffset : Int? = nil, propertiesToFetch : [String]? = nil, descriptorArray : [NSSortDescriptor]? = nil, currentContex : NSManagedObjectContext? = nil) -> NSArray{
        
        let moc : NSManagedObjectContext = currentContex ?? dataStack.mainMOC
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: enityName as String, in: moc)!
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: enityName as String)
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        if let propertiesFetch = propertiesToFetch {
            fetchRequest.propertiesToFetch = propertiesFetch
        }
        
        if let offSet = fetchOffset {
            fetchRequest.fetchOffset = offSet
        }
        
        fetchRequest.fetchLimit = fetchLimit
        
        if let sortDescriptors = descriptorArray {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        fetchRequest.resultType = .managedObjectResultType
        
        var result:Any? =  nil
        do {
            result = try moc.fetch(fetchRequest)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        return result as! NSArray
        
    }
    
    func fetchManageObjectsDictionaryForEnity(enityName : NSString, predicate : NSPredicate, fetchLimit : Int,  fetchOffset : Int? = nil, propertiesToFetch : [String]? = nil, descriptorArray : [NSSortDescriptor]? = nil, currentContex : NSManagedObjectContext? = nil) -> NSArray{
        
        let moc : NSManagedObjectContext = currentContex ?? dataStack.mainMOC
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: enityName as String, in: moc)!
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: enityName as String)
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        if let propertiesFetch = propertiesToFetch {
            fetchRequest.propertiesToFetch = propertiesFetch
        }
        
        if let offSet = fetchOffset {
            fetchRequest.fetchOffset = offSet
        }
        
        fetchRequest.fetchLimit = fetchLimit
        
        if let sortDescriptors = descriptorArray {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        fetchRequest.resultType = .dictionaryResultType
        
        var result:Any? =  nil
        do {
            result = try moc.fetch(fetchRequest)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        return result as! NSArray
        
    }
    
    //MARK: // ----------Fetch manageObject For Entity with NSSortDescriptor-------------//
    func fetchManageObjectForEnity(enityName : NSString, predicate : NSPredicate, descriptorArray : [NSSortDescriptor]? = nil, currentContex : NSManagedObjectContext? = nil) -> NSArray{
        
        let moc : NSManagedObjectContext = currentContex ?? dataStack.mainMOC
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: enityName as String, in: moc)!
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: enityName as String)
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        if let sortDescriptors = descriptorArray {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        var result:Any? =  nil
        do {
            result = try moc.fetch(fetchRequest)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        return result as! NSArray
        
    }
    
    //MARK: // ----------Fetch manageObject For Entity-------------//
    func fetchManageObjectForEnity(enityName : NSString ,predicate : NSPredicate , currentContex : NSManagedObjectContext? = nil) -> NSArray{
        
        let moc : NSManagedObjectContext = currentContex ?? dataStack.mainMOC
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: enityName as String, in: moc)!
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: enityName as String)
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        var result:Any? =  nil
        do {
            result = try moc.fetch(fetchRequest)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        return result as! NSArray
        
    }
    
    //MARK: // ----------Fetch manageObject For Entity With sortDescriptors-------------//
    func fetchManageObjectForEnityWithSortDescriptor(enityName : NSString ,predicate : NSPredicate ,sortDescriptors : [NSSortDescriptor]? = nil, currentContex : NSManagedObjectContext? = nil) -> NSArray?{
        
        let moc : NSManagedObjectContext = currentContex ?? dataStack.mainMOC
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: enityName as String, in: moc)!
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: enityName as String)
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        if  let   descriptors = sortDescriptors{
            fetchRequest.sortDescriptors = descriptors
        }
        var result:Any? =  nil
        do {
            result = try moc.fetch(fetchRequest)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        return result as? NSArray
        
    }
    
    
    //MARK: // --------Fetch object with current private context------------//
    func fetchManageObjectOnContextForEnity(enityName : NSString ,predicate : NSPredicate,context : NSManagedObjectContext?) -> NSArray{
        
        let  moc : NSManagedObjectContext?
        
        if  let currentContext : NSManagedObjectContext  = context {
            
            moc = currentContext
            
        }else {
            
            moc = dataStack.mainMOC
        }
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: enityName as String, in: moc!)!
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: enityName as String)
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        var result:Any? =  nil
        do {
            result = try moc?.fetch(fetchRequest)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        
        return result as! NSArray
    }
    //MARK; // ----------Fetch Request for any entity----------//
    func fetchRequest(forEntity c: AnyClass!) -> NSFetchRequest<NSFetchRequestResult>! {
        
        return NSFetchRequest(entityName: getClassName(forClass: c))
        
    }
    
    func getClassName(forClass c:AnyClass!) -> String{
        return NSStringFromClass(c).components(separatedBy: ".").last!
    }
    
    
    func fetchResults(forRequest  fetchRequest:NSFetchRequest<NSFetchRequestResult> , currentContext : NSManagedObjectContext?) -> NSArray{
        
        let moc : NSManagedObjectContext?
        
        if  let  context = currentContext {
            
            moc = context
        }else {
            
            moc = dataStack.mainMOC
        }
        
        var result : NSArray? = nil
        do {
            result = try moc?.fetch(fetchRequest) as NSArray?
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return result!
    }
    
}
