//
//  FirstViewController.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import UIKit
import SQLite

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRowDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addItemButton: UIButton!
    
    let db = Database()
    
    func UpdateNewRowData(mode: RowMode, row: FlowRow) {
        
        if mode == .Add {
            db.rows.append(row)
        } else {
            if let index = db.rows.index(where: { $0.id == row.id }) {
               db.rows[index] = row
            }
        }
        
        self.db.sortRows()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Simple Cash Flow"
        self.tableView.backgroundColor = UIColor.Ca$h.purple
        self.addItemButton.backgroundColor = UIColor.Ca$h.pink
        self.addItemButton.tintColor = UIColor.white
        self.addItemButton.layer.cornerRadius = 22.5
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        
        let tableHeader = UILabel()
        tableHeader.backgroundColor = UIColor.Ca$h.greyishPurple
        tableHeader.text = "Sup B"
        tableHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50.0)
        self.tableView.tableHeaderView = tableHeader
        
        navigationController?.navigationBar.barTintColor = UIColor.Ca$h.darkPurple
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addRowButton() {
        segueToItem(mode: .Add, indexPath: nil)
    }
    
    func segueToItem(mode: RowMode, indexPath: IndexPath?) {
        let addEditRowVC = self.storyboard?.instantiateViewController(withIdentifier: "AddRowViewController") as! AddRowViewController
        
        addEditRowVC.delegate = self
        addEditRowVC.db = self.db
        addEditRowVC.mode = mode
        
        if mode == .Edit {
            addEditRowVC.editingRow = db.rows[indexPath!.row]
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = UIColor.Ca$h.pink
        navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(addEditRowVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return db.rows.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CashFlowTableViewCell", for: indexPath) as! CashFlowTableViewCell
        
        let fr = self.db.rows[indexPath.row]
        
        cell.dateLabel.text = fr.shortDateString
        
        cell.descriptionLabel.text = fr.description
        
        cell.cashLabel.text = String(format: "$%.2f", fr.flowAmount)
        
        switch fr.type {
        case .Inflow:
            cell.cashLabel.textColor = UIColor.green
        case .Outflow:
            cell.cashLabel.textColor = UIColor.red
        }
        
        //TODO: Compute the totals in a more sensible way. Don't rely on the UI. Could probably sort the rows based on date in the model, then compute total from there
        //TODO: Create headers for each month in the table
        
        if indexPath.row == 0 {
            cell.totalLabel.text = String(format: "$%.2f", fr.flowAmount)
            self.db.rows[indexPath.row].total = fr.flowAmount
        } else {
            //Total = previous total +- cash inflow/outflow
            let total = self.db.rows[indexPath.row - 1].total + fr.flowAmount
            
            self.db.rows[indexPath.row].total = total
            cell.totalLabel.text = String(format: "$%.2f", total)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let rowToDelete = db.rows[indexPath.row]
            
            //Delete data from array
            db.rows.remove(at: indexPath.row)
            
            //Delete data from storage
            db.deleteFlowFromDatabase(flow: rowToDelete)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.Ca$h.greyishPurple
        self.tableView.deselectRow(at: indexPath, animated: true)
        segueToItem(mode: .Edit, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UILabel()
        headerView.backgroundColor = UIColor.Ca$h.pink
        headerView.textColor = UIColor.white
        headerView.text = "Date          Desc          Inflow/Outflow          Total"
        
        return headerView
    }
    
}

