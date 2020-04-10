//
//  CreateReportUserNameCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit

protocol CreateReportUserNameCellDelegate : class {

    func nameInputDidSubmit(_ userInput : String?)
}


class CreateReportUserNameCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var lblName : UILabel!
    @IBOutlet private weak var textField : UITextField!
    @IBOutlet private weak var profileImgVw : UIImageView!
    weak var delegate : CreateReportUserNameCellDelegate?

    private var inputFormFieldModel : ReportFormInputFieldModel?

    override func awakeFromNib() {
       super.awakeFromNib()
       initialSetup()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialSetup()-> Void{
        
        profileImgVw.layer.cornerRadius = profileImgVw.bounds.width / 2
        profileImgVw.layer.borderWidth = 1.0
        profileImgVw.layer.borderColor = UIColor.black.cgColor
        textField.clearButtonMode = .whileEditing
    }
    
    public func populateUserNameFormFieldCell(with formModel : ReportFormInputFieldModel?){
        
        inputFormFieldModel = formModel
        lblName.text = formModel?.fieldName
        if let userName = formModel?.answerInput as? String{
            textField.text = userName
        }
    }

}

extension CreateReportUserNameCell : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
        if let inputText = textField.text, !inputText.isEmpty{
            delegate?.nameInputDidSubmit(inputText)
        }
        
        /*
      if inputFormFieldModel?.isRequiredField == true{
          //dipay validation error
          let alertVC = UIAlertController.init(title: "Error", message: "Field can't be left blank !!!", preferredStyle: .alert)
          let cancelAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
          alertVC.addAction(cancelAction)
          alertVC.present(true, completion: nil)
          
      } */
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
