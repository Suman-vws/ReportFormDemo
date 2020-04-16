//
//  CreateReportViewController.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit


class CreateReportViewController: UIViewController, StoryboardViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var arrFormInputFieldData : [ReportFormInputFieldModel]?
    var arrFormInputFieldDictionary : [Dictionary<String, Any>]?
    var selectedReportDetailsModel : ReportModel?

    private var tableInitialContentHeight : CGFloat!
    private var reportDetailsModel = ReportModel()
    private var hasReportUpdated : Bool = false
    
    var didCreateReportCompletion : ((_ associatedReportModel : ReportModel?, _ hasUpdate : Bool) -> Void)?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customizeNavigationBar()
        
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = UITableView.automaticDimension
        registerNibsForTableView()
        
        if let reportModel = selectedReportDetailsModel {       //initialing report model for editing
            reportDetailsModel = reportModel
        }
        
        tableInitialContentHeight = tableView.bounds.size.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        
        if parent == nil {
            didCreateReportCompletion?(reportDetailsModel, hasReportUpdated)
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        print("De-initialization")
    }

    
    //MARK: Keyboard Notifications
    
    @objc private func keyboardWillChangeFrame(_ notification : Notification) {
        
        var showkeyboard : Bool!
        
        if notification.name == UIResponder.keyboardWillHideNotification{       //hide keyboard
            showkeyboard = false
        }else if notification.name == UIResponder.keyboardWillShowNotification{ //show keyboard
            showkeyboard = true
        }
        
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = curFrame.origin.y - targetFrame.origin.y
        
        adjustViewPositionOnKeyboardHeightChange(deltaY, hideKeyboard: showkeyboard)

//        if deltaY >= 0{
//            print("delta Y : \(deltaY)")
//            adjustViewPositionOnKeyboardHeightChange(deltaY, hideKeyboard: showkeyboard)
//        }

      
    }
    
    private func adjustViewPositionOnKeyboardHeightChange(_ keyBoardHeight : CGFloat, hideKeyboard : Bool){
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: UIView.AnimationOptions.curveEaseInOut, animations: { [weak self] in

            self?.tableView.contentSize = CGSize(width: (self?.tableView.contentSize.width ?? 0.0), height: (self?.tableInitialContentHeight)! + keyBoardHeight)
        
            },
            completion: { (completed) in

            })
    }
    
    private func registerNibsForTableView(){
        
        tableView.register(UINib(nibName: CreateReportUserNameCell.nibName, bundle: nil), forCellReuseIdentifier: CreateReportUserNameCell.defaultReuseIdentifier)
        
        tableView.register(UINib(nibName: CreateReportTextFieldCell.nibName, bundle: nil), forCellReuseIdentifier: CreateReportTextFieldCell.defaultReuseIdentifier)

        tableView.register(UINib(nibName: CreateReportMultilineTextInputCell.nibName, bundle: nil), forCellReuseIdentifier: CreateReportMultilineTextInputCell.defaultReuseIdentifier)

        tableView.register(UINib(nibName: CreateReportDropdownCell.nibName, bundle: nil), forCellReuseIdentifier: CreateReportDropdownCell.defaultReuseIdentifier)

    }
    
    
    //MARK: // - - - - - - - UI Setup helper - - - - - - - //
    private func customizeNavigationBar(){
        self.navigationItem.title = "Create Report"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveReportButtonTapped(_:)))
    }
    
    //MARK: // - - - - - - - Create report Save Events - - - - - - - //
    
    @objc func saveReportButtonTapped(_ sender : UIBarButtonItem){
        self.view.endEditing(true)
        
        if validateReportFormInputs() {
            hasReportUpdated = true     //flag for denoting if the report has been modified

            if reportDetailsModel.createDate == nil{ //applicable for edit action
                reportDetailsModel.createDate = Date()
            }

            if reportDetailsModel.reportJsonFilePath == nil{
                let timestamp = Date().currentTimeMillis()
                reportDetailsModel.reportJsonFilePath = "\(timestamp)"
            }
            
            CoreDataManager.sharedStore.upsertReportDetails(reportDetailsModel) { [weak self] (success) in
                
                if ReportDemoUtility.checkJsonFileExists(folderPath: ReportFormJsonFileSavePath, fileName: "\(self?.reportDetailsModel.reportJsonFilePath ?? "")") == false {       //json file write action in document directory
                    
                    let formattedDict = self?.reportDetailsModel.createReportDictFormUserInput()
                    print("\(formattedDict ?? [:])")
                    //saving form data into Json file, in Document directory
                    let jsonString = self?.arrFormInputFieldDictionary?.jsonStringRepresentation ?? ""
                    ReportDemoUtility.saveReportJsonDataInDocumentDirectory(jsonString, folderPath: ReportFormJsonFileSavePath, fileName: "\(self?.reportDetailsModel.reportJsonFilePath ?? "")")
                }
          
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    private func displayValidationErrorAlert(with messege : String){
        
        let alertVC = UIAlertController.init(title: "Error", message: messege, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        
        alertVC.present(true, completion: nil)
    }
    
    
    private func validateReportFormForMandetoryFields()->String{
        
        let mandetoryFormFields = arrFormInputFieldData?.filter{($0.isRequiredField == true)}
        var errorMessege = ""
        
        if let arrFormFields = mandetoryFormFields {
            
            for item in arrFormFields {
                
                let itemType = item.fieldType
                
                switch itemType {
                    
                case .userField:
                    if let _ = reportDetailsModel.name{
                        if reportDetailsModel.name!.isEmpty{
                            errorMessege = "User name field can't be left blank !!!"
                        }
                    }else{
                        errorMessege = "User name field can't be left blank !!!"
                    }

                case .textualInputField:
                    if let _ = reportDetailsModel.designation, reportDetailsModel.designation!.isEmpty{
                       errorMessege = "Designation field can't be left blank !!!"
                    }else{
                        errorMessege = "Designation field can't be left blank !!!"
                    }
                    
                case .numericInputField:
                    if let age = reportDetailsModel.age, let min = item.minValue , let max = item.maxValue{
                        
                        if age < min {
                            errorMessege = "Age value should be greater than or equal to \(min) & less than or equal to \(max)"
                        }else if age > max {
                            errorMessege = "Age value should be greater than or equal to \(min) & less than or equal to \(max)"
                        }
                    }else{
                        errorMessege = "Age field can't be left blank !!!"
                    }
                case .multilineInputField:
                    if let _ = reportDetailsModel.address, reportDetailsModel.address!.isEmpty{
                        errorMessege = "Address field can't be left blank !!!"
                    }else{
                        errorMessege = "Address field can't be left blank !!!"
                    }

                default:
                        break
                }
            }
            
        }
        
        return errorMessege
    }
    
    
    private func validateReportFormInputs()-> Bool{

        let errorString = validateReportFormForMandetoryFields()
        
        if !errorString.isEmpty{
            displayValidationErrorAlert(with: errorString)
            return false
        }
        
        if let numericFormFields = arrFormInputFieldData?.filter({($0.fieldType == .numericInputField)}){
            var numericFieldError : String?
            for item in numericFormFields {
                if let age = reportDetailsModel.age{
                    if let min = item.minValue , let max = item.maxValue{
                        if age < min {
                            numericFieldError = "Age value should be greater than or equal to \(min) & less than or equal to \(max)"
                        }else if age > max {
                            numericFieldError = "Age value should be greater than or equal to \(min) & less than or equal to \(max)"
                        }
                    }

                }else{
                    numericFieldError = "Age field can't be left blank !!!"
                }
            }
            
            if let strError = numericFieldError, !strError.isEmpty{
                displayValidationErrorAlert(with: strError)
               return false
            }
        }
        
        return true //valid input
    }
    
}

//MARK: // - - - - - - - Button Events - - - - - - - //
extension CreateReportViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFormInputFieldData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let inputFieldModel = arrFormInputFieldData?[indexPath.row]
        
        switch inputFieldModel?.fieldType {
            
        case .userField:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateReportUserNameCell.defaultReuseIdentifier, for: indexPath) as! CreateReportUserNameCell
            cell.delegate = self
            cell.populateUserNameFormFieldCell(with: inputFieldModel)
            cell.selectionStyle = .none
            return cell

        case .textualInputField, .numericInputField:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateReportTextFieldCell.defaultReuseIdentifier, for: indexPath) as! CreateReportTextFieldCell
            cell.delegate = self
            cell.populateTextualFormFieldCell(with: inputFieldModel)
            cell.selectionStyle = .none
            return cell

        case .multilineInputField:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateReportMultilineTextInputCell.defaultReuseIdentifier, for: indexPath) as! CreateReportMultilineTextInputCell
            cell.delegate = self
            cell.populateMultilineFormFieldCell(with: inputFieldModel)
            cell.selectionStyle = .none
            return cell

        case .dropDownSelection:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateReportDropdownCell.defaultReuseIdentifier, for: indexPath) as! CreateReportDropdownCell
            cell.populateDropdownFormFieldCell(with: inputFieldModel)
            cell.selectionStyle = .none
            return cell

        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "")
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let inputFieldModel = arrFormInputFieldData?[indexPath.row]

        switch inputFieldModel?.fieldType {
            
        case .dropDownSelection:        //navigate to dropdown option selection
            
            let mainStroryBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let dropDownMenuVC = mainStroryBoard.instantiateViewController(withIdentifier: ReportDropdownMenuViewController.storyBoardIdentifier) as! ReportDropdownMenuViewController
            
            if let arrSelectionOptions = inputFieldModel?.arrOptions, !arrSelectionOptions.isEmpty{
                let arrDropdownSelectionModel = arrSelectionOptions.map { (selecteionFieldValue) -> DropDownSelectionOptionModel in
                    
                    var dropDownSelectedStyle = DropDownSelectionOptionCategory.deselected
                    if let currentSelection = inputFieldModel?.answerInput as? String, currentSelection == selecteionFieldValue{
                        dropDownSelectedStyle = DropDownSelectionOptionCategory.selected
                    }
                    
                    let dropdownSelectionModel = DropDownSelectionOptionModel(selectedValue: selecteionFieldValue, selectedOptionType: dropDownSelectedStyle)
                   return dropdownSelectionModel
                }
                dropDownMenuVC.arrDropDownOption = arrDropdownSelectionModel
                dropDownMenuVC.strMenuTitle = inputFieldModel?.fieldName
            }
            //popview controller callback
            dropDownMenuVC.optionSelectionDismissCompletion = { [weak self] (selectedOption) in
                
                if let currentFieldModel = self?.arrFormInputFieldData?[indexPath.row], currentFieldModel.fieldType == .dropDownSelection{
                    
                    self?.arrFormInputFieldData?[indexPath.row].answerInput = selectedOption
                    if currentFieldModel.fieldName == "hobbies"{
                        self?.reportDetailsModel.hobbies = selectedOption
                    }else if currentFieldModel.fieldName == "gender"{
                        self?.reportDetailsModel.gender = selectedOption
                    }
                }
                
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            self.navigationController?.pushViewController(dropDownMenuVC, animated: true)
            
        default:
            break
        }
    }
    
}

extension CreateReportViewController : CreateReportUserNameCellDelegate, CreateReportTextInputCellDelegate, MultilineTextInputCellDelegate {

    //MARK: // - - - - -  CreateReportUserNameCellDelegate - - - - - - //
    func nameInputDidSubmit(_ userInput: String?) {
        if let _ = userInput {
            reportDetailsModel.name = userInput
        }
    }
    
    //MARK: // - - - - -  CreateReportTextInputCellDelegate - - - - - - //
    func textInputDidSubmit(_ userInput: String?, inputFieldType: ReportFieldType?) {
        
        if inputFieldType == .numericInputField {
            reportDetailsModel.age = Int(userInput!)
            
        }else if inputFieldType == .textualInputField {
            reportDetailsModel.designation = userInput
        }
    }
    
    
    
    //MARK: // - - - - -  MultilineTextInputCellDelegate - - - - - - //
    func multilineTextVwDidEndEditing(_ inputText: String) {
        reportDetailsModel.address = inputText
    }
    
    func resizeableTextViewHeightDidChange(cell: UITableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}

