//
//  ReportDetailsTableCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit

public enum ReportDetailsCellType : Int {
    
//    case userNameCell = 0
    case userAddressCell = 1
    case otherDetailsCell = 2
    
    static func getReportDetailsCellType(from formInputFieldType: ReportFieldType)->ReportDetailsCellType{
        
        if formInputFieldType == .multilineInputField{
            return .userAddressCell
        }else{
            return .otherDetailsCell
        }
    }
}

class ReportDetailsTableCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var imgVwTrailingConst : NSLayoutConstraint!
    @IBOutlet private weak var imgVwWidthConst : NSLayoutConstraint!
    
    @IBOutlet private weak var profileImgVw : UIImageView!
    @IBOutlet private weak var lblFieldName : UILabel!
    @IBOutlet private weak var lblFieldValue : UILabel!


    override func awakeFromNib() {
       super.awakeFromNib()
       initialSetup()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialSetup()-> Void{
        profileImgVw?.layer.cornerRadius = profileImgVw.bounds.width / 2
        profileImgVw.layer.borderWidth = 1.0
        profileImgVw.layer.borderColor = UIColor.black.cgColor
    }

    //MARK: // - - - - - UI Config Helper - - - - - - //
    
    
    private func setupDetailsLabelFontType(cellType : ReportDetailsCellType){
                
        if cellType == .otherDetailsCell {
            lblFieldValue.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        }else if cellType == .userAddressCell{
            lblFieldValue.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)
        }
    }
    
    private func showProfileImageVw(){
        
        imgVwTrailingConst.constant = 15
        imgVwWidthConst.constant = 75
    }
    
    private func hideProfileImageVw(){
        
        imgVwTrailingConst.constant = 0
        imgVwWidthConst.constant = 0
    }

    public func setupReportDetailsCell(with formFieldModel : ReportFormInputFieldModel?){
        
        lblFieldName.text = formFieldModel?.fieldName
        
        if let formFieldType = formFieldModel?.fieldType, formFieldType == .numericInputField{
            let answer = formFieldModel?.answerInput as? Int
            lblFieldValue.text = "\(answer!)"
        }else{
            lblFieldValue.text = formFieldModel?.answerInput as? String
        }
        
        if let formFieldType = formFieldModel?.fieldType{
            if formFieldType == .userField{
                showProfileImageVw()
            }else{
                hideProfileImageVw()
            }
            
            let reportDetailscellType = ReportDetailsCellType.getReportDetailsCellType(from: formFieldType)
            setupDetailsLabelFontType(cellType: reportDetailscellType)
        }
           
    }
    

}
