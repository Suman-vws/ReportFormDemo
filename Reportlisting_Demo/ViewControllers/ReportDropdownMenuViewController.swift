//
//  ReportDropdownMenuViewController.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 08/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit


public enum DropDownSelectionOptionCategory : Int {
    case deselected = 0
    case selected = 1
}

struct DropDownSelectionOptionModel {
    
    let selectedValue : String
    var selectedOptionType : DropDownSelectionOptionCategory
}


class ReportDropdownMenuViewController: UIViewController, StoryboardViewController {
    
    @IBOutlet weak var tableView : UITableView!
    private var userSelectedOption : DropDownSelectionOptionModel?
    var arrDropDownOption : [DropDownSelectionOptionModel]?
    var strMenuTitle : String?
    var optionSelectionDismissCompletion : ((_ selectedOption : String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: ReportDropDownOptionsCell.nibName, bundle: nil), forCellReuseIdentifier: ReportDropDownOptionsCell.defaultReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        
        if parent == nil, let selectedOptionValue = self.userSelectedOption?.selectedValue{
            optionSelectionDismissCompletion?(selectedOptionValue)
        }
    }
    
    deinit {
        print("De-initialization")
    }
    
    
    //MARK: // - - - - - - - UI Setup helper - - - - - - - //
    private func customizeNavigationBar(){
        self.navigationItem.title = (strMenuTitle != nil) ? "select" + " " + strMenuTitle! : "Dropdown Selection"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.submitOptionSelection(_:)))
    }
    
    
    //MARK: // - - - - - - - Button Events - - - - - - - //
    
    @objc func submitOptionSelection(_ sender : UIBarButtonItem){
        if let selectedOptions = arrDropDownOption?.filter({$0.selectedOptionType == .selected}), selectedOptions.count == 1{
            userSelectedOption = selectedOptions.first  //stores the selected value
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ReportDropdownMenuViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDropDownOption?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReportDropDownOptionsCell.defaultReuseIdentifier, for: indexPath) as! ReportDropDownOptionsCell

        let selectionModel = arrDropDownOption?[indexPath.row]
        cell.feedDropdownSelectionOption(selectionOption: selectionModel?.selectedValue ?? "")
        
        if selectionModel?.selectedOptionType == .selected{
            cell.enableSelection()
        }else{
            cell.disableSelection()
        }
        cell.selectionStyle = .none

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        deselectPreviousSelection()
        arrDropDownOption?[indexPath.row].selectedOptionType = .selected
        tableView.reloadData()
    }
    
    private func deselectPreviousSelection(){
     
        //forcefully reset all previous selection
        if let arrOptions = arrDropDownOption, !arrOptions.isEmpty{
           let arrDropdownSelectionModel = arrOptions.map { (optionModel) -> DropDownSelectionOptionModel in
               let dropdownSelectionModel = DropDownSelectionOptionModel.init(selectedValue: optionModel.selectedValue, selectedOptionType: .deselected)
              return dropdownSelectionModel
           }
           
           arrDropDownOption = arrDropdownSelectionModel
        }
    }
}
