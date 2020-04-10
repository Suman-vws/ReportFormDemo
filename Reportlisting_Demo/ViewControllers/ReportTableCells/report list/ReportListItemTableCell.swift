//
//  ReportListItemTableCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit

class ReportListItemTableCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var lblUserName : UILabel!
    @IBOutlet private weak var lblCreateDate : UILabel!
    @IBOutlet private weak var lblSecondaryInfo : UILabel!
    @IBOutlet private weak var profileImgVw : UIImageView!

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
    }

    
    public func populateReportListItemCell(with reportModel : ReportModel?){
        
        lblUserName.text = reportModel?.name ?? ""
        lblSecondaryInfo.text = getSecondaryInformationText(with: reportModel)
        
        //test data
//        let cal = Calendar.current
//        let pastDate = cal.date(byAdding: .day, value: 15, to: Date())!
        lblCreateDate.text = getFormattedDateStringFrom(reportModel?.createDate)
    }
    
    private func getFormattedDateStringFrom(_ date : Date?) -> String {
        
        guard let createDate = date else{
            return ""
        }
        
        if Calendar.current.isDateInToday(createDate){
            return "Today"
        }else if Calendar.current.isDateInYesterday(createDate){
            return "Yesterday"
        }else{
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strDate = dateFormatterGet.string(from: createDate)
            
            let dateFormatterSet = DateFormatter()
            dateFormatterSet.dateFormat = "dd MMM"
            
            return dateFormatterSet.string(from: dateFormatterGet.date(from: strDate)!)
        }
        
    }
    
    private func getSecondaryInformationText(with reportModel : ReportModel?) -> String{
        
        let mutableString = NSMutableString(string: "")
        if let age = reportModel?.age, age > 0 {
            let strAgeDescription = "Age : " + "\(age)"
            mutableString.append(strAgeDescription)
            
            if let gender = reportModel?.gender {
                mutableString.append("\t\t")
                mutableString.append(gender)
            }
            
        }else if let gender = reportModel?.gender {
           mutableString.append(gender)
            
            if let designation = reportModel?.designation {
                mutableString.append("\t\t")
                mutableString.append(designation)
            }
       }
        
        return  mutableString as String
    }
}
