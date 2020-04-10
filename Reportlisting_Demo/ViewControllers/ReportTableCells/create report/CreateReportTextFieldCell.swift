//
//  CreateReportTextFieldCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit


protocol CreateReportTextInputCellDelegate : class {

    func textInputDidSubmit(_ userInput : String?, inputFieldType : ReportFieldType?)
}

class CreateReportTextFieldCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var lblName : UILabel!
    @IBOutlet private weak var textField : UITextField!
    weak var delegate : CreateReportTextInputCellDelegate?
    
    private var inputFormFieldModel : ReportFormInputFieldModel?

    override func awakeFromNib() {
       super.awakeFromNib()
       initialSetup()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialSetup()-> Void{

    }
    
    public func populateTextualFormFieldCell(with formModel : ReportFormInputFieldModel?){
       
        inputFormFieldModel = formModel
        lblName.text = formModel?.fieldName
        
        if inputFormFieldModel?.fieldType == ReportFieldType.numericInputField {
            textField.keyboardType = .numberPad
        }else if inputFormFieldModel?.fieldType == ReportFieldType.textualInputField{
            textField.keyboardType = .namePhonePad
        }
        
        //setting up answer
        if inputFormFieldModel?.fieldType == ReportFieldType.numericInputField {
           if let userAge = formModel?.answerInput as? Int{
               textField.text = "\(userAge)"
           }
        }else if inputFormFieldModel?.fieldType == ReportFieldType.textualInputField{
           if let userDesignation = formModel?.answerInput as? String{
               textField.text = userDesignation
           }
        }
    }

}

extension CreateReportTextFieldCell : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let inputText = textField.text, !inputText.isEmpty{
            delegate?.textInputDidSubmit(inputText, inputFieldType: inputFormFieldModel?.fieldType)
        }
    }
}
