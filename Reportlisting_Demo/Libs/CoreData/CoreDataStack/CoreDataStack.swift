//
//  CoreDataStack.swift
//  Lists
//
//  Created by Suman Chatterjee on 28/05/19.
//  Copyright © 2019 Suman Chatterjee. All rights reserved.
//

import Foundation
import CoreData


fileprivate enum StoreType {
    case inMemory
    case sqLite(storeURL: URL)
}

public enum DataStackError: Swift.Error {
    
    case storeNotFound(at: URL)
    case memoryStoreMissing
    case unableToCreateStore(at: URL)
}


// General Action CallBacks
public typealias DataStackSetUpHandler = (CoreDataStack.SetupResult) -> Void
public typealias DataStoreResetHandler = (CoreDataStack.ResetResult) -> Void
public typealias BatchContextHandler = (CoreDataStack.BatchContextResult) -> Void


public final class CoreDataStack {
    
    //MARK:  - - - - - - - Properties - - - - - - -
    private let managedObjectModelName: String
    private let bundle: Bundle
    private var storeType: StoreType
    
    public static var storeUrl : URL?
    public static var isMigrationTure : Bool = false
    public static var currentManagedObjectModel: NSManagedObjectModel?

    
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator  { //fileprivate
        didSet {
            workerMOC = constructWorkerWOC()
            workerMOC.persistentStoreCoordinator = persistentStoreCoordinator
            mainMOC = constructMainMOC()
        }
    }
    
    private var managedObjectModel : NSManagedObjectModel { //fileprivate
        
        if let currentModel = CoreDataStack.currentManagedObjectModel {
            
            return  currentModel
            
        }else{
            
            return bundle.managedObjectModel(name: managedObjectModelName)
        }
    }
    
    // MARK:  - - - - - - - Initialization - - - - - - -
    private init(storeName: String, bundle: Bundle, persistentStoreCoordinator: NSPersistentStoreCoordinator, storeType: StoreType, storeURL : URL?) {
        
        self.bundle = bundle
        self.storeType = storeType
        CoreDataStack.storeUrl = storeURL
        self.managedObjectModelName = storeName
        self.persistentStoreCoordinator = persistentStoreCoordinator
        self.workerMOC.persistentStoreCoordinator = persistentStoreCoordinator       //setting up the parent store for root context
    }
 
    
    public static func createSQLiteStore(storeName: String, in bundle: Bundle = Bundle.main, at desiredStoredURL: URL? = nil, persistentStoreOptions: [AnyHashable: Any]? = NSPersistentStoreCoordinator.stockSQLiteStoreOptions, on callBackQueue: DispatchQueue? = nil, callback: @escaping DataStackSetUpHandler ) {
        
        let store = bundle.managedObjectModel(name: storeName)  //returns the managedObject Model
        CoreDataStack.currentManagedObjectModel = store
        
        
        let storeURL = desiredStoredURL ?? URL(string: "\(storeName).sqlite", relativeTo: documentsDirectory!)!
        
        print("Store URL: \(storeURL)")
        CoreDataStack.storeUrl = storeURL
        
        var storeMigrationOption : [AnyHashable : Any]?
        
        if isMigrationRequired(){
            
            CoreDataStack.isMigrationTure = true
            storeMigrationOption = NSPersistentStoreCoordinator.stockSQLiteStoreMigrationOptions
            
        }else{
            
            CoreDataStack.isMigrationTure = false
            storeMigrationOption = persistentStoreOptions
            
        }
        
        
        do {
            
            try createDirectoryIfNecessary(storeURL)
            
        } catch {
            
            callback(.failure(DataStackError.unableToCreateStore(at: storeURL)))
            return
            
        }
        
        
        let bcQueue = DispatchQueue.global(qos: .background)
        let callbackQueue = callBackQueue ?? bcQueue
        NSPersistentStoreCoordinator.setupSQLiteBackedCoordinator(store, storeFileURL: storeURL, persistentStoreOptions: storeMigrationOption) { coordinatorResult in
            switch coordinatorResult {
            case .sucess(let coordinator):
                
                let stack = CoreDataStack.init(storeName: storeName, bundle: bundle, persistentStoreCoordinator: coordinator, storeType: .sqLite(storeURL: storeURL) ,storeURL: storeURL)
                callbackQueue.async {
                    callback(.sucess(stack))
                }
            case .failure(let error):
                callbackQueue.async {
                    callback(.failure(error))
                }
            }
            
        }
        
    }
    
    
    public static func createInMemoryStore(storeName: String, in bundle: Bundle = Bundle.main) throws -> CoreDataStack {
        
        let store = bundle.managedObjectModel(name: storeName)
        let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: store)
        let bStack = CoreDataStack.init(storeName: storeName, bundle: bundle, persistentStoreCoordinator: persistentStoreCoordinator, storeType: .inMemory, storeURL: nil)
        return bStack
    }
    
    private static func createDirectoryIfNecessary(_ url: URL) throws -> Void {
        let fileManager = FileManager.default
        
        let directory = url.deletingLastPathComponent()
        
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    // MARK: - Destractor

    deinit {
        print("De-initializing CoreDataStack")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    //MARK:  - - - - - - - Configure managed contexts - - - - - - -
    public private(set) lazy var workerMOC: NSManagedObjectContext = {
        return self.constructWorkerWOC()
    }()
    
    private func constructWorkerWOC() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        managedObjectContext.name = "Private Queue Top Level Context"
        return managedObjectContext
    }
    
    
    public private(set) lazy var mainMOC: NSManagedObjectContext = {
        return self.constructMainMOC()
    }()
    
    private func constructMainMOC() -> NSManagedObjectContext {
        
        var managedObjectContext: NSManagedObjectContext!
        
        let setup: () -> Void = {
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
            managedObjectContext.parent = self.workerMOC
        }
        
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                setup()
            }
        }
        else{
            setup()
        }
        return managedObjectContext
    }
}

//MARK: // - - - - - - - - - PUBLIC EXTENSIONS - - - - - - - - - //

public extension Bundle {
    
    static private let modelExtension = "momd"
    static private let modelAlternateExtension = "mom"
    
    
    fileprivate func managedObjectModel(name: String) -> NSManagedObjectModel {
        
        var momPath : String? = Bundle.main.path(forResource: name, ofType: Bundle.modelExtension) ?? ""
        
        if let _ =  momPath {
            
        }else{
            
            momPath = Bundle.main.path(forResource: name, ofType: Bundle.modelAlternateExtension)!
            
        }
        
        let url : URL = URL(fileURLWithPath: momPath ?? "")
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            
            preconditionFailure("Model not found or corrupted with name: \(name) in bundle: \(self)")
            
        }
        
        return model
    }
}


//MARK: // - - - - - - - - - Core Data Stack public extensions - - - - - - - - - //

public extension CoreDataStack {
    
    public func newChildMOC(type: NSManagedObjectContextConcurrencyType = .privateQueueConcurrencyType, name: String = "Main Queue Child Managed Object Context") -> NSManagedObjectContext {
        
        if type == .mainQueueConcurrencyType && !Thread.isMainThread {
            
            preconditionFailure("Main thread MOC should be always created on Main Thread")
        }
        
        
        let moc = NSManagedObjectContext(concurrencyType: type)
        moc.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        moc.parent = self.mainMOC
        moc.name = name

        return moc
    }
    
    public func getContextForCurrentThread() -> NSManagedObjectContext {
        
        let nContext: NSManagedObjectContext
        
        if Thread.isMainThread {
            nContext =  self.mainMOC
        }else{
            nContext = newChildMOC()
        }
        return nContext
    }
}


public extension CoreDataStack {        // - - - - - - - - - Document Directory Helper - - - - - - - - //
    
    public static var documentsDirectory: URL?{
        get {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls[0]
        }
    }
}
public extension CoreDataStack {
    
    public enum CoordinatorResult {
        case sucess(NSPersistentStoreCoordinator)
        case failure(Swift.Error)
    }
    
    public enum BatchContextResult {
        case sucess(NSManagedObjectContext)
        case failure(Swift.Error)
    }
    
    public enum SetupResult {
        case sucess(CoreDataStack)
        case failure(Swift.Error)
    }
    
    public enum SuccessResult {
        case sucess
        case failure(Swift.Error)
    }
    
    public typealias SaveResult = SuccessResult
    public typealias ResetResult = SuccessResult
}


//MARK: // - - - - - - - - - CoreDataStack Migration Helper - - - - - - - - //

public extension  CoreDataStack{
    
    static var  stackObjectModel : NSManagedObjectModel {       //-------- computed property in swift extension-----------
        get{
            return  CoreDataStack.currentManagedObjectModel!
        }
        set{
            if CoreDataStack.currentManagedObjectModel != newValue{
                CoreDataStack.currentManagedObjectModel = newValue
            }
        }
    }
    
    static var  sourceStoreURL : URL {
        
        let storeFileURL = CoreDataStack.storeUrl! //FileManager.default.urlToApplicationSupportDirectory().appendingPathComponent("\(kSILDataStoreName).sqlite")
        
        return  storeFileURL
        
    }
    
    
    public static func  isMigrationRequired() -> Bool{      //---------Check Migation is Needed or not--------
        
        // Check if we need to migrate
        let sourceMetaData : [String : Any]? = { () -> [String : Any]? in
            
            do{
                print("\(CoreDataStack.storeUrl!)")
                return  try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType , at: CoreDataStack.storeUrl!)
                
            }catch let error as NSError{
                
                print("\(error)")
                return nil
            }
            
        }()
        
        var  destinationModel : NSManagedObjectModel {
            
            get{
                
                return stackObjectModel
                
            }
            
        }
        
        var  isMigrationNeeded : Bool = false
        
        if let metaData = sourceMetaData {
            
            // Migration is needed if destinationModel is NOT compatible
            let success = destinationModel.isConfiguration(withName: "", compatibleWithStoreMetadata: metaData)
            
            if success {
                
                isMigrationNeeded = false
                
            }else{
                
                isMigrationNeeded = true
            }
            
        }
        
        return  isMigrationNeeded
    }
    
}
