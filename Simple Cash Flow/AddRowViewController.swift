//
//  AddRowViewController.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import UIKit
import SQLite

class AddRowViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var flowField: UITextField!
    
    var delegate: AddRowDelegate?
    var db: Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Row"
        
        dateField.placeholder = "Date"
        descriptionField.placeholder = "Description"
        flowField.placeholder = "Amount"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemPressed() {
        
        guard let date = dateField.text else { return }
        guard let desc = descriptionField.text else { return }
        guard let flow = flowField.text else { return }
        
        guard let doubleFlow = Double(flow) else { return }
        
        //TODO: GET THIS OUT OF THE VIEW CONTROLLER 
        
        let dateColumn = Expression<String>("date")
        let description = Expression<String>("description")
        let flowAmount = Expression<Double>("flowAmount")
        
        let cashFlows = Table("cashFlows")
        
        do {
            let rowid = try db!.run(cashFlows.insert(dateColumn <- date, description <- desc, flowAmount <- doubleFlow))
            delegate?.UpdateNewRowData(id: rowid, date: date, description: desc, flow: doubleFlow, total: 0.0)
            print("inserted id: \(rowid)")
        } catch {
            print("insertion failed: \(error)")
        }
        
        
        
        self.navigationController?.popViewController(animated: true)
    }
    

}//end class
