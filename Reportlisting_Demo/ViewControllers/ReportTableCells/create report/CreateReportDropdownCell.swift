//
//  CreateReportDropdownCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit

class CreateReportDropdownCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var lblFieldName : UILabel!
    @IBOutlet private weak var lblFieldInputValue : UILabel!
    private var inputFormFieldModel : ReportFormInputFieldModel?


    override func awakeFromNib() {
       super.awakeFromNib()
       initialSetup()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialSetup()-> Void{

//        lblFieldInputValue.layer.borderWidth = 1.0
//        lblFieldInputValue.layer.borderColor = UIColor.black.cgColor
    }

    public func populateDropdownFormFieldCell(with formModel : ReportFormInputFieldModel?){

        inputFormFieldModel = formModel
        lblFieldName.text = formModel?.fieldName
        
        if let userInput = formModel?.answerInput as? String, !userInput.isEmpty{
            lblFieldInputValue.text = userInput
        }

    }
}
