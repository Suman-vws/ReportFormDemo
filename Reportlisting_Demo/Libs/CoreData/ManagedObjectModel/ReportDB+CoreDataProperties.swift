//
//  ReportDB+CoreDataProperties.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 09/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//
//

import Foundation
import CoreData


extension ReportDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReportDB> {
        return NSFetchRequest<ReportDB>(entityName: "ReportDB")
    }

    @NSManaged public var address: String?
    @NSManaged public var age: Int16
    @NSManaged public var createDate: Date?
    @NSManaged public var designation: String?
    @NSManaged public var gender: String?
    @NSManaged public var hobbies: String?
    @NSManaged public var jsonFileSavePath: String?
    @NSManaged public var name: String?
    @NSManaged public var applicationId: String?

}
