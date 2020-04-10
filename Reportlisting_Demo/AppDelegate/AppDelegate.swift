//
//  AppDelegate.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        CoreDataStack.createSQLiteStore(storeName: "ReporDemo") { [weak dataManager = CoreDataManager.sharedStore] result in
            switch result {
            case .sucess(let stack):
               dataManager?.dataStack = stack
               print("Data Stack Setup Successful")
            case .failure(let error):
               assertionFailure("\(error)")
            }
        }
        return true
    }


}

