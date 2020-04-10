//
//  ReportFieldModel.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 08/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation

struct ReportFormInputFieldModel {
    
    let uniqueId : Int
    let fieldName : String
    let fieldType : ReportFieldType  //set mapper to convert Enum from string
    let isRequiredField : Bool?
    let arrOptions : [String]?
    let minValue : Int?
    let maxValue : Int?
    var answerInput : Any?    //user answer
    
    init(_uniqueId : Int, _fieldName : String, _type : ReportFieldType, _isRequired : Bool?, _dropDownOptions : [String]? = nil, _minValue : Int? = nil, _maxValue : Int? = nil) {
        
        uniqueId = _uniqueId
        fieldName = _fieldName
        fieldType = _type
        isRequiredField = _isRequired
        arrOptions = _dropDownOptions
        minValue = _minValue
        maxValue = _maxValue
    }
    
    static func generateFormModel(formFieldDict : [String : Any]) -> ReportFormInputFieldModel{
        
        let uniqueId = formFieldDict[fieldUniqueIdKey] as! Int
        
        let name = formFieldDict[fieldNameKey] as! String
        
        let strType = formFieldDict[fieldTypeKey] as! String
        let fieldType = ReportFieldType.createFieldEnumFrom(strType)
        
        let isRequired = formFieldDict[fieldIsRequiredKey] as? Bool
        let options = formFieldDict[fieldOptionsValueKey] as? [String]
        let minValue = formFieldDict[fieldMinValueKey] as? Int
        let maxValue = formFieldDict[fieldMaxValueKey] as? Int

        
        let formInputFieldModel = ReportFormInputFieldModel(_uniqueId: uniqueId, _fieldName: name, _type: fieldType, _isRequired: isRequired, _dropDownOptions: options, _minValue: minValue, _maxValue: maxValue)
        
        return formInputFieldModel
    }
    
}


struct ReportModel {
    
    var name : String?
//    let dateOfBirth : String
    var age : Int?
    var address : String?
    var designation : String?
    var gender : String?
    var hobbies : String?
    var createDate : Date?
    var reportJsonFilePath : String?
    
    func createReportDictFormUserInput()-> [String:Any]{
        
        var formFieldDict : [String : Any] = [:]
            
        formFieldDict["Name"] = name!
        
        if let _ = age{
            formFieldDict["Age"] = age!
        }
        
        if let _ = designation{
            formFieldDict["Designation"] = designation!
        }
        
        if let _ = gender{
            formFieldDict["Gender"] = gender!
        }
        
        if let _ = hobbies{
            formFieldDict["Hobbies"] = hobbies!
        }
        
        if let _ = address{
            formFieldDict["Address"] = address!
        }
        
        return formFieldDict
    }
    
    
    static func createReportModel(from reportDBObj : ReportDB?)-> ReportModel{
        
        var reportModel = ReportModel()
        
        reportModel.name = reportDBObj?.name
        if let age = reportDBObj?.age{
           reportModel.age = Int(age)
        }
        reportModel.designation =  reportDBObj?.designation
        reportModel.gender = reportDBObj?.gender
        reportModel.hobbies = reportDBObj?.hobbies
        reportModel.address = reportDBObj?.address
        reportModel.createDate = reportDBObj?.createDate
        reportModel.reportJsonFilePath = reportDBObj?.jsonFileSavePath
        
        return  reportModel
    }

}
