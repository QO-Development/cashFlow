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
    @IBOutlet weak var itemButton: UIButton!
    
    var delegate: AddRowDelegate?
    var db: Database?
    var mode: RowMode?
    var editingRow: FlowRow?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch mode! {
        case .Add:
            self.title = "Add Cash Flow"
            self.itemButton.setTitle("Add Item", for: .normal)
        case .Edit:
            self.title = "Edit Cash Flow"
            self.itemButton.setTitle("Edit Item", for: .normal)
            self.dateField.text = editingRow?.longDateString
            self.descriptionField.text = editingRow?.description
            self.flowField.text = "\(editingRow!.flowAmount)"
        }
        
        self.view.backgroundColor = UIColor.Ca$h.purple
        itemButton.backgroundColor = UIColor.Ca$h.pink
        itemButton.tintColor = UIColor.white
        
        dateField.placeholder = "Date, e.g. 7/3/2018"
        descriptionField.placeholder = "Description"
        flowField.placeholder = "Amount"
        
        itemButton.layer.cornerRadius = 5.0
        
        dateField.keyboardType = .numbersAndPunctuation
        descriptionField.keyboardType = .alphabet
        flowField.keyboardType = .numbersAndPunctuation
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemPressed() {
        
        guard let dateString = dateField.text else {
            print("No dateString")
            return
        }
        guard let desc = descriptionField.text else {
            print("No description")
            return
        }
        guard let flow = flowField.text else {
            print("flow")
            return
        }
        guard let doubleFlow = Double(flow) else {
            print("Invalid flow")
            return
        }
        
        switch mode! {
        case .Add:
            addItem(dateString: dateString, desc: desc, doubleFlow: doubleFlow)
        case .Edit:
            editItem(dateString: dateString, desc: desc, doubleFlow: doubleFlow)
        }
    }
    
    func editItem(dateString: String, desc: String, doubleFlow: Double) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let date = dateFormatter.date(from: dateString) else {
            print("Check your date format is equal to MM/dd/yyyy")
            return
        }
        
        let updatedRow = FlowRow(id: self.editingRow!.id, date: date, description: desc, total: 0.0, flowAmount: doubleFlow)
        
        do {
            //Update database
            try db?.updateRowInDatabase(fr: updatedRow)
            //Update model in memory
            delegate?.UpdateNewRowData(mode: .Edit, row: updatedRow)
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Check the error. Unable to edit")
        }
    }
    
    func addItem(dateString: String, desc: String, doubleFlow: Double) {
        do {
            if let tuple = try db?.insertRowIntoDatabase(dateString: dateString, description: desc, cashFlow: doubleFlow) {
                let newRow = FlowRow(id: tuple.rowId, date: tuple.date, description: desc, total: 0.0, flowAmount: doubleFlow)
                delegate?.UpdateNewRowData(mode: .Add, row: newRow)
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            print("Can't segue. Check errors.")
        }
    }
    
}//end class






















