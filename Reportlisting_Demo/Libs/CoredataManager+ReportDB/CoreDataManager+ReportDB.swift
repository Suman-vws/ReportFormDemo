//
//  CoreDataManager+ReportDB.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 09/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataManager {
    
    private func setValueForReportDB(from reportModelObj : ReportModel, reportDBObject : ReportDB) {

        reportDBObject.applicationId = "Reportlisting_Demo" //static idetifier
        reportDBObject.name = reportModelObj.name
        reportDBObject.age = Int16(reportModelObj.age ?? 0)
        reportDBObject.gender = reportModelObj.gender
        reportDBObject.designation = reportModelObj.designation
        reportDBObject.createDate = reportModelObj.createDate
        reportDBObject.hobbies = reportModelObj.hobbies
        reportDBObject.address = reportModelObj.address
        reportDBObject.jsonFileSavePath = reportModelObj.reportJsonFilePath
    }
    
    
    public func upsertReportDetails(_ reportModelObj : ReportModel, closure : @escaping((_ status : Bool ) -> Void)) {
        
        if let savePath = reportModelObj.reportJsonFilePath, !savePath.isEmpty{

            var reportDb : ReportDB?
            
            let reportContext = CoreDataManager.sharedStore.fetchPrivateContext()
            let reportPredicate : NSPredicate = NSPredicate(format: "jsonFileSavePath = %@", savePath)
            
            let resultArr : NSArray = self.fetchManageObjectForEnity(enityName: ReportDBEntity as NSString,predicate: reportPredicate , currentContex: reportContext)
            
            if resultArr.count > 0 {
                reportDb = resultArr.firstObject as? ReportDB
            }else{
                let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ReportDBEntity , in: reportContext)!
                reportDb = ReportDB(entity: entity, insertInto: reportContext)
            }

            setValueForReportDB(from: reportModelObj, reportDBObject: reportDb!)
            
            reportContext.saveContextToStore({ _ in
               closure(true)
            })
        }
    }
    
    public func deleteReportDetails(_ reportModelObj : ReportModel, closure : @escaping((_ status : Bool ) -> Void)) {
          
          if let savePath = reportModelObj.reportJsonFilePath, !savePath.isEmpty{
              
            let reportContext = CoreDataManager.sharedStore.fetchPrivateContext()
            let reportPredicate : NSPredicate = NSPredicate(format: "jsonFileSavePath = %@", savePath)
            let resultArr : NSArray = self.fetchManageObjectForEnity(enityName: ReportDBEntity as NSString,predicate: reportPredicate , currentContex: reportContext)

            if resultArr.count > 0 {
                let reportDb = resultArr.firstObject as! ReportDB
                reportContext.delete(reportDb)
            }
            
            reportContext.saveContextToStore({ _ in
                closure(true)
            })
          }
      }
    
    
    func fetchAllReports() -> [ReportDB?] {
        
        let moc: NSManagedObjectContext = fetchMainContext()
        let applicationId = "Reportlisting_Demo"

        let reportPredicate : NSPredicate = NSPredicate(format: "applicationId = %@", applicationId)
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)

        return self.fetchManageObjectForEnity(enityName: ReportDBEntity as NSString, predicate: reportPredicate, descriptorArray: [sortDescriptor], currentContex: moc) as! [ReportDB]
    }
    
    func fetchAllReportsFromCurrentDate() -> [ReportDB?] {
        
        let moc: NSManagedObjectContext = fetchMainContext()
        let applicationId = "Reportlisting_Demo"
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let startOfDay = calendar.startOfDay(for: Date())
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = calendar.date(byAdding: components, to: startOfDay)!

        let reportPredicate = NSPredicate(format: "applicationId = %@ AND createDate >= %@ AND createDate < %@", applicationId, startOfDay as CVarArg, endOfDay as CVarArg)

        return self.fetchManageObjectForEnity(enityName: ReportDBEntity as NSString, predicate: reportPredicate, currentContex: moc) as! [ReportDB]
    }
}
