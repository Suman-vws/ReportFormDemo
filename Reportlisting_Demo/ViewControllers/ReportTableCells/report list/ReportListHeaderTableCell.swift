//
//  ReportListHeaderTableCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit

class ReportListHeaderTableCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var lblTotalReportCount : UILabel!
    @IBOutlet private weak var lblCurrentDayReportCount : UILabel!

    override func awakeFromNib() {
       super.awakeFromNib()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func populateReportListHeaderCell(){
        
        let arrReportDB = CoreDataManager.sharedStore.fetchAllReports()
        lblTotalReportCount.text = "\(arrReportDB.count)"
        
        let arrReportsFromToday = CoreDataManager.sharedStore.fetchAllReportsFromCurrentDate()
//        lblCurrentDayReportCount.text = "Today's Report: \(arrReportsFromToday.count)"
        
        //set up attributed string
        let masterAttributedString = NSMutableAttributedString(string:"")

        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.foregroundColor : UIColor.white] as [NSAttributedString.Key : Any]
        let attrbutedStr1 = NSMutableAttributedString(string: "Today's Report : ", attributes:attrs1)

        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .heavy), NSAttributedString.Key.foregroundColor : UIColor.white] as [NSAttributedString.Key : Any]
        let attrbutedStr2 = NSMutableAttributedString(string:"\(arrReportsFromToday.count)", attributes:attrs2)

        masterAttributedString.append(attrbutedStr1)
        masterAttributedString.append(attrbutedStr2)

        lblCurrentDayReportCount.attributedText = masterAttributedString
        
    }


}
