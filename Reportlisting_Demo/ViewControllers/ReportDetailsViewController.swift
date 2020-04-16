//
//  ReportDetailsViewController.swift
//  Reportlisting_Demo
//
//  Created by Suman Chatterjee on 07/04/2020.
//  Copyright © 2020 Suman Chatterjee. All rights reserved.
//

import Foundation
import UIKit


class ReportDetailsViewController: UIViewController, StoryboardViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var reportModel : ReportModel?
    private var arrFormInputFieldData : [ReportFormInputFieldModel]?
    private var hasReportDetailsContainChange : Bool = false
    var didUpdateReportDeatilsCompletion : ((_ hasChanges : Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = UITableView.automaticDimension
        registerNibsForTableView()
        
        createReportDetailsFormInputDataWithUserInput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    deinit {
        print("De-initialization")
    }
    
    
    override func willMove(toParent parent: UIViewController?) {
        
        if parent == nil {
            didUpdateReportDeatilsCompletion?(hasReportDetailsContainChange)
        }
    }
    
    private func createReportDetailsFormInputDataWithUserInput(){
        
        if let arrFormInputData = generateReportFormData(){
            var arrTempFormInputData : [ReportFormInputFieldModel] = []
            for formFieldModel in arrFormInputData {
                var formInputModel = formFieldModel
                formInputModel = ReportDemoUtility.setupReportFormModelWithUserInput(reportDetailsModel: reportModel!, formInputField: formFieldModel)
                arrTempFormInputData.append(formInputModel)
            }
            arrFormInputFieldData = arrTempFormInputData
        }
        tableView.reloadData()
    }
    
    private func generateReportFormData()-> [ReportFormInputFieldModel]?{
        
        if let currentReportModel = reportModel{
            
            let reportFormJson = ReportDemoUtility.getReportJsonFileSavePath(folderPath: ReportFormJsonFileSavePath, fileName: "\(currentReportModel.reportJsonFilePath ?? "")")
            
            if let arrFormInput = reportFormJson, !arrFormInput.isEmpty{
                let arrFormModel = arrFormInput.map { (inputFieldDict) -> ReportFormInputFieldModel in
                    let inputModel = ReportFormInputFieldModel.generateFormModel(formFieldDict: inputFieldDict)
                    return inputModel
                }
                return arrFormModel.sorted(by: {$0.uniqueId < $1.uniqueId})
            }
        }
        
        return nil
    }
    
    private func registerNibsForTableView(){
        tableView.register(UINib(nibName: ReportDetailsTableCell.nibName, bundle: nil), forCellReuseIdentifier: ReportDetailsTableCell.defaultReuseIdentifier)
    }
    
    //MARK: // - - - - - - - UI Setup helper - - - - - - - //
    private func customizeNavigationBar(){
        self.navigationItem.title = "Report Details"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editReportDetailsButtonTapped))
    }
    
    
    //MARK: // - - - - - - - Report Details Edit Button Events - - - - - - - //
    
    @objc func editReportDetailsButtonTapped(){

        let mainStroryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let createReportVC = mainStroryBoard.instantiateViewController(withIdentifier: CreateReportViewController.storyBoardIdentifier) as! CreateReportViewController
        // - - - - get saved json input - - - - //
        if let currentReportModel = reportModel{
            createReportVC.selectedReportDetailsModel = currentReportModel

            let reportFormJson = ReportDemoUtility.getReportJsonFileSavePath(folderPath: ReportFormJsonFileSavePath, fileName: "\(currentReportModel.reportJsonFilePath ?? "")")
            createReportVC.arrFormInputFieldDictionary = reportFormJson
            createReportVC.arrFormInputFieldData = arrFormInputFieldData
        }
        
        createReportVC.didCreateReportCompletion = { [weak self] (reportDetailsModel, hasUpdate) in
            if hasUpdate{
                self?.hasReportDetailsContainChange = true
                self?.reportModel = reportDetailsModel
                self?.createReportDetailsFormInputDataWithUserInput()
            }
        }

        self.navigationController?.pushViewController(createReportVC, animated: true)
    }
    
}

extension ReportDetailsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFormInputFieldData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReportDetailsTableCell.defaultReuseIdentifier, for: indexPath) as! ReportDetailsTableCell
        let formInputModel = arrFormInputFieldData?[indexPath.row]
//        cell.delegate = self
        cell.setupReportDetailsCell(with: formInputModel)
        cell.selectionStyle = .none
        return cell
    }
    
   
}

