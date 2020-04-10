//
//  ReportListViewController.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit


class ReportListViewController: UIViewController, StoryboardViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var lblNoReportsAvailable : UILabel!

    private var arrReports : [ReportModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //patch for coredata stack initialization
        self.view.showActivity()
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.view.hideActivity()
            self?.arrReports = self?.fetchSavedReports()
            self?.tableView.reloadData()
        }   //End patch
        
        lblNoReportsAvailable.isHidden = true
        customizeNavigationBar()
        
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = UITableView.automaticDimension
        registerNibsForTableView()
        
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        print("De-initialization")
    }
    
    
    private func registerNibsForTableView(){
        
        tableView.register(UINib(nibName: ReportListHeaderTableCell.nibName, bundle: nil), forCellReuseIdentifier: ReportListHeaderTableCell.defaultReuseIdentifier)
        tableView.register(UINib(nibName: ReportListItemTableCell.nibName, bundle: nil), forCellReuseIdentifier: ReportListItemTableCell.defaultReuseIdentifier)
    }
    
    private func fetchSavedReports()-> [ReportModel]? {
        
        let arrReportDB = CoreDataManager.sharedStore.fetchAllReports()
        let arrFormModel = arrReportDB.map { (reportDb) -> ReportModel in
            let reportModelObj = ReportModel.createReportModel(from: reportDb)
            return reportModelObj
        }

        return arrFormModel
    }
    
    //MARK: // - - - - - - - UI Setup helper - - - - - - - //
    private func customizeNavigationBar(){
        
       //ui customization
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#0b7adb") // "#1e88e5"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0, weight: .bold), NSAttributedString.Key.foregroundColor : UIColor.white] as [NSAttributedString.Key : Any]
        
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.tintColor = .white

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addNewReportButtonTapped(_:)))
    }
    
    
    private func showNoReportsAvailableView(){
        lblNoReportsAvailable.isHidden = false
        tableView.isHidden = true
    }
    
    private func hideNoReportsAvailableView(){
        lblNoReportsAvailable.isHidden = true
        tableView.isHidden = false
    }
    
    //MARK: // - - - - - - - Button Events - - - - - - - //
    
    @objc func addNewReportButtonTapped(_ sender : UIBarButtonItem){
       
        let mainStroryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let createReportVC = mainStroryBoard.instantiateViewController(withIdentifier: CreateReportViewController.storyBoardIdentifier) as! CreateReportViewController
        // - - - - get random json input - - - - //
        let reportFormJson = ReportJsonDataProvider.getRandomReportJson()
        createReportVC.arrFormInputFieldDictionary = reportFormJson
        createReportVC.arrFormInputFieldData = getReportFormInputData(from: reportFormJson)
        createReportVC.didCreateReportCompletion = { [weak self] (reportDetailsModel, hasUpdate) in
            if hasUpdate{
                self?.arrReports = self?.fetchSavedReports()
                self?.tableView.reloadData()
            }
        }
        
        self.navigationController?.pushViewController(createReportVC, animated: true)
    }
    
    
    private func getReportFormInputData(from jsonData : [Dictionary<String, Any>]?)-> [ReportFormInputFieldModel]? {

       if let arrFormInput = jsonData, !arrFormInput.isEmpty{
           let arrFormModel = arrFormInput.map { (inputFieldDict) -> ReportFormInputFieldModel in
               let inputModel = ReportFormInputFieldModel.generateFormModel(formFieldDict: inputFieldDict)
               return inputModel
           }
           
          return arrFormModel.sorted(by: {$0.uniqueId < $1.uniqueId})
       }
       
       return nil
       
    }
}

//mARK: // - - - - - Tableview Delegate - - - - - //
extension ReportListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let reports = arrReports, !reports.isEmpty{
            hideNoReportsAvailableView()
        }else{
            showNoReportsAvailableView()
        }
        
        let currentSection = ReportListSectionCategory(rawValue : section)
        switch currentSection {
        case .ReportHeaderSection:
            return (arrReports != nil) ? 1 : 0   //patch for coredata stack initialization

        case .ReportListSection:
            return arrReports?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentSection = ReportListSectionCategory(rawValue : indexPath.section)
        
        if currentSection == .ReportHeaderSection{
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportListHeaderTableCell.defaultReuseIdentifier, for: indexPath) as! ReportListHeaderTableCell
            cell.contentView.backgroundColor = UIColor(hexString: "#52a0e3") // #3494E8
//            cell.delegate = self
            cell.populateReportListHeaderCell()
            cell.selectionStyle = .none
            return cell
            
        }else if currentSection == .ReportListSection{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReportListItemTableCell.defaultReuseIdentifier, for: indexPath) as! ReportListItemTableCell
            let reportModel = arrReports?[indexPath.row]
//            cell.delegate = self
            cell.populateReportListItemCell(with: reportModel)
            cell.selectionStyle = .none
            return cell
            
        }else{
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let reportModel = arrReports?[indexPath.row]{
            navigateToReportDetailsScreen(reportModel)
        }
    }
    
    private func navigateToReportDetailsScreen(_ currentReportModel : ReportModel){
        
        let mainStroryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let reportDetailsVC = mainStroryBoard.instantiateViewController(withIdentifier:
            
        ReportDetailsViewController.storyBoardIdentifier) as! ReportDetailsViewController
        reportDetailsVC.reportModel = currentReportModel
        reportDetailsVC.didUpdateReportDeatilsCompletion = { [weak self] (hasUpdate) in
            if hasUpdate{
                self?.arrReports = self?.fetchSavedReports()
                self?.tableView.reloadData()
            }
        }

        self.navigationController?.pushViewController(reportDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let currentSection = ReportListSectionCategory(rawValue : indexPath.section)!
        if currentSection == .ReportListSection{
            return true
        }else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction.init(style: .destructive, title: "Delete") { [weak self] (action, indexpath) in
         
            if let currentReportModel = self?.arrReports?[indexPath.row]{
                CoreDataManager.sharedStore.deleteReportDetails(currentReportModel) { (success) in
                    DispatchQueue.main.async {
                        self?.arrReports?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        // - - - for table header section data update - - - //
                        let headerIndexPath = IndexPath.init(row: 0, section: 0)
                        tableView.reloadRows(at: [headerIndexPath], with: .automatic)
                    }
                }
            }
                 
        }
        /*
        let editAction = UITableViewRowAction.init(style: .normal, title: "Edit") { (action, indexpath) in
        }
        editAction.backgroundColor = UIColor.lightGray  */

        return [deleteAction]
    }
    
}


