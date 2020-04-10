//
//  CreateReportMultilineTextInputCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit

protocol MultilineTextInputCellDelegate : class {

    func resizeableTextViewHeightDidChange(cell : UITableViewCell)
    func multilineTextVwDidEndEditing(_ inputText : String)

}

class CreateReportMultilineTextInputCell : UITableViewCell, ReusableView, NibLoadableView{

    @IBOutlet private weak var lblName : UILabel!
    @IBOutlet private weak var multilineTxtVw : UITextView!
    weak var delegate : MultilineTextInputCellDelegate?
    private var inputFormFieldModel : ReportFormInputFieldModel?

    override func awakeFromNib() {
       super.awakeFromNib()
       initialSetup()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialSetup()-> Void{

        multilineTxtVw.delegate = self
        multilineTxtVw.isScrollEnabled = false
        
//        multilineTxtVw.layer.borderWidth = 1.0
//        multilineTxtVw.layer.borderColor = UIColor.black.cgColor
    }
    
    
    public func populateMultilineFormFieldCell(with formModel : ReportFormInputFieldModel?){
       
       inputFormFieldModel = formModel
       lblName.text = formModel?.fieldName
        
        if let userAddress = formModel?.answerInput as? String{
            multilineTxtVw.text = userAddress
        }
    }

}


extension CreateReportMultilineTextInputCell : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.resizeableTextViewHeightDidChange(cell: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
       if(text == "\n") {
           textView.resignFirstResponder()
           return false
       }
       return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.multilineTextVwDidEndEditing(textView.text)
    }
}
