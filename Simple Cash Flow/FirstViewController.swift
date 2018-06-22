//
//  FirstViewController.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import UIKit
import SQLite3
import SQLite

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRowDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var rows: [FlowRow] = []
    
    let database = Database()
    var db: Connection?
    
    func UpdateNewRowData(id: Int64, date: String, description: String, flow: Double, total: Double) {
        
        let newRow = FlowRow(id: id, date: date, description: description, total: total, flowAmount: flow)
        rows.append(newRow)
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Simple Cash Flow"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if let db = database.getConnection() {
            //Use this connection later
            self.db = db
            database.createCashFlowsTableIfNotExists(db: db)
            
            //Get the data and append it to rows
            self.rows = database.selectAllCashFlows(db: db)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addRowButton() {
        let addRowVC = self.storyboard?.instantiateViewController(withIdentifier: "AddRowViewController") as! AddRowViewController
        addRowVC.delegate = self
        addRowVC.db = self.db
        self.navigationController?.pushViewController(addRowVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CashFlowTableViewCell", for: indexPath) as! CashFlowTableViewCell
        
        let fr = self.rows[indexPath.row]
        
        cell.dateLabel.text = fr.date
        
        cell.descriptionLabel.text = fr.description
        
        cell.cashLabel.text = String(format: "$%.2f", fr.flowAmount)
        
        //TODO: Compute the totals in a more sensible way. Don't rely on the UI. Could probably sort the rows based on ID in the model, then compute total from there
        
        if indexPath.row == 0 {
            cell.totalLabel.text = String(format: "$%.2f", fr.flowAmount)
            self.rows[indexPath.row].total = fr.flowAmount
        } else {
            //Total = previous total +- cash inflow/outflow
            let total = self.rows[indexPath.row - 1].total + fr.flowAmount
            
            self.rows[indexPath.row].total = total
            cell.totalLabel.text = String(format: "$%.2f", total)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            
            let rowToDelete = rows[indexPath.row]
            
            //Delete data from array
            rows.remove(at: indexPath.row)
            
            //Delete data from storage
            //TODO: FIX THIS CONNECTION STUFF
            database.deleteFlowFromDatabase(db: self.db!, flow: rowToDelete)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
   
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UILabel()
        headerView.backgroundColor = UIColor.lightGray
        headerView.text = "Date       Desc       Inflow/Outlfow       Total"
        
        return headerView
    }
    
}

