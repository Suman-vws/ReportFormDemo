//
//  ReportDemo+Utility.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit


//MARK: //  - - - - - -  Commom Protocol  - - - - - - //

//MARK: Get Reuse-Identifier for UITableViewCell Or, UIcolletionViewCel
protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}


//MARK: Get Nib Name

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

//MARK: Get Nib Name

protocol NibLoadableViewController: class {
    static var nibName: String { get }
}

extension NibLoadableViewController where Self: UIViewController {
    
    static var nibName: String {
        return String(describing: self)
    }
}

protocol StoryboardViewController: class {
    static var storyBoardIdentifier: String { get }
}

extension StoryboardViewController where Self: UIViewController {
    
    static var storyBoardIdentifier: String {
        return String(describing: self)
    }
}


//MARK: // - - - - - Public Enums - - - - - - //

public enum ReportListSectionCategory : Int{
    
    case ReportHeaderSection = 0
    case ReportListSection = 1
}

public enum UserGenderType : Int{
    
    case male = 0
    case female = 1
    case other = 2
    
    
}

public enum ReportFieldType : Int {
    
    case unknown = 0
    case userField = 1
    case textualInputField = 2
    case numericInputField = 3
    case multilineInputField = 4
    case dropDownSelection = 5
    case dateInputField = 6
    
    
    static func createFieldEnumFrom(_ typeStringValue : String) -> ReportFieldType{
        
        var fieldType = ReportFieldType.unknown
        
        switch typeStringValue {
            case "user":
                fieldType = .userField
            case "number":
                fieldType = .numericInputField
            case "dropdown":
                fieldType = .dropDownSelection
            case "text":
                fieldType = .textualInputField
            case "multiline":
                fieldType = .multilineInputField
            default:
                break
        }
        
        return fieldType
    }
}


//MARK: // - - - - - Json Provider - - - - - - //

public class ReportJsonDataProvider {
    
    class func getRandomReportJson()->[Dictionary<String, Any>]?{
                
        if let path = Bundle.main.path(forResource: "reports", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String : Any], let reports = jsonResult["reports"] as? [Dictionary<String, Any>], !reports.isEmpty {
                            // do stuff
                    let reportData = reports.randomElement()
                    if let reportFormData = reportData?["report"] as? [Dictionary<String, Any>], !reportFormData.isEmpty{
                        return reportFormData
                    }
                  }
              } catch {
                   // handle error
                print("Json file not found")
                return nil
              }
            
        }
        
        return nil
    }
    
}


class ReportDemoUtility {
    
    class func getReportJsonFileSavePath(folderPath : String, fileName : String) -> [Dictionary<String, Any>]?{
        
        let filePathUrl = FileManager.documentDirectoryURL.appendingPathComponent("ReportDemo/\(folderPath)/\(fileName)").appendingPathExtension("json")
        
        if FileManager.default.fileExists(atPath: filePathUrl.path) {
            do {
                let jsonString = try String(contentsOf: filePathUrl, encoding: .utf8)
                return jsonString.convertToDictionary()
            }
            catch {
                print(error.localizedDescription);
            }
        }
        
        return nil
    }
    
    
    class func saveReportJsonDataInDocumentDirectory(_ jsonString : String, folderPath : String, fileName : String){
                
        let filePathUrl = FileManager.documentDirectoryURL.appendingPathComponent("ReportDemo/\(folderPath)/\(fileName)").appendingPathExtension("json")
        
        if !FileManager.default.fileExists(atPath: filePathUrl.path) {
            do {
                try FileManager.default.createDirectory(atPath: filePathUrl.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                
                do {
                    
                    try jsonString.write(to: filePathUrl, atomically: false, encoding: .utf8)
                    print("file saved at path : <<<<----- \(filePathUrl.absoluteString) ----->>>>")
                }
                catch {
                    print(error.localizedDescription);
                    print("file save error : <<<<----- \(filePathUrl.absoluteString) ----->>>>")
                }
                
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
    }
    
    class func setupReportFormModelWithUserInput(reportDetailsModel : ReportModel, formInputField : ReportFormInputFieldModel?) -> ReportFormInputFieldModel{
        
        var formInputFieldModel = formInputField
        
        let itemType = formInputFieldModel?.fieldType
        
        switch itemType {
            
        case .userField:
            if let name = reportDetailsModel.name{
                formInputFieldModel?.answerInput = name
            }
        case .textualInputField:
            if let designation = reportDetailsModel.designation /* ,  formInputFieldModel.fieldName == "designation"    */{
               formInputFieldModel?.answerInput = designation
            }
        case .numericInputField:
            if let age = reportDetailsModel.age /*,  formInputFieldModel.fieldName == "number"  */{
               formInputFieldModel?.answerInput = age
            }
        case .multilineInputField:
            if let address = reportDetailsModel.address /* , reportDetailsModel.address!.isEmpty    */{
                formInputFieldModel?.answerInput = address
            }
        case .dropDownSelection:
            if let selectedOption = reportDetailsModel.gender, formInputFieldModel?.fieldName == "gender"{
               formInputFieldModel?.answerInput = selectedOption
            }else if let selectedOption = reportDetailsModel.hobbies, formInputFieldModel?.fieldName == "hobbies"{
               formInputFieldModel?.answerInput = selectedOption
            }
        default:
                break
        }
        
        return formInputFieldModel!
    }

}


extension FileManager {
    
    static var documentDirectoryURL: URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectoryURL
    }
    
}


extension Array {
    
    var jsonStringRepresentation: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}

extension Date {
  func currentTimeMillis() -> Int64 {
      return Int64(self.timeIntervalSince1970 * 1000)
    }

}

extension String {
    
    func convertToDictionary() -> [Dictionary<String, Any>]? {
        
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Dictionary<String, Any>]
//                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}


//MARK: // - - - - - Constants  - - - - - //
let fieldNameKey = "field_name"
let fieldTypeKey = "type"
let fieldUniqueIdKey = "unique_id"
let fieldIsRequiredKey = "required"
let fieldMinValueKey = "min"
let fieldMaxValueKey = "max"
let fieldOptionsValueKey = "options"

let ReportFormJsonFileSavePath = "Report_forms"
let ReportDBEntity = "ReportDB"

