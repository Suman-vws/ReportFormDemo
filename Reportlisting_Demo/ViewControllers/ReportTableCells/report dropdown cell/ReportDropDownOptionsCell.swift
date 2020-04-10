//
//  ReportDropDownOptionsCell.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit



class ReportDropDownOptionsCell : UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet private weak var lblSelectionOption : UILabel!
    @IBOutlet private weak var imgVwSelectionBox : UIImageView!
//    var selectionOptionType : DropDownOptionSelectionOptions = .deselected

    override func awakeFromNib() {
       super.awakeFromNib()
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func feedDropdownSelectionOption(selectionOption : String)-> Void{
        lblSelectionOption.text = selectionOption
    }

    public func enableSelection(){
//        selectionOptionType = .selected
        imgVwSelectionBox.image = UIImage.init(named: "check")
    }
    
    public func disableSelection(){
//        selectionOptionType = .deselected
        imgVwSelectionBox.image = UIImage.init(named: "uncheck")
    }

}
