//
//  Database.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/21/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import Foundation
import SQLite

enum InsertError: Error {
    case InvalidDateFormat
    case DatabaseInsertError
}

class Database {
    
    // Table Columns
    let idColumn = Expression<Int64>("id")
    let dateColumn = Expression<String>("date")
    let descriptionColumn = Expression<String>("description")
    let flowAmountColumn = Expression<Double>("flowAmount")
    ///////////////////////////////////////////////////////////////
    
    let cashFlowsTable = Table("cashFlows")
    
    var connection: Connection?
    var rows: [FlowRow] = []
    
    init() {
        //Initialize the DB connection
        self.getConnection()
        
        //Create the cash flows table if needed
        self.createCashFlowsTableIfNotExists()
        
        //Get the cash flows data and append it to rows
        self.rows = self.selectAllCashFlows()
        
    }
        
    func getConnection() {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("cashDatabase.sqlite")
        
        do {
            let db = try Connection(fileURL.path)
            self.connection = db
        } catch {
            print("Unable to connect to DB")
        }
    }
    
    func updateRowInDatabase(fr: FlowRow) throws {
        
        let row = cashFlowsTable.filter(idColumn == fr.id)
        
        do {
            print("Hi")
            try self.connection?.run(row.update(dateColumn <- fr.longDateString, descriptionColumn <- fr.description, flowAmountColumn <- fr.flowAmount))
        } catch {
            print("Unable to update database")
            print(error)
            throw error
        }
    }
    
    func insertRowIntoDatabase(dateString: String, description: String, cashFlow: Double) throws -> (rowId: Int64, date: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let date = dateFormatter.date(from: dateString) else {
            print("Check your date format is equal to MM/dd/yyyy")
            throw InsertError.InvalidDateFormat
            //return 0
        }
    
        do {
            if let rowid = try self.connection?.run(cashFlowsTable.insert(dateColumn <- dateString, descriptionColumn <- description, flowAmountColumn <- cashFlow)) {
                print("inserted id: \(rowid)")
                return (rowid, date)
            } else {
                throw InsertError.DatabaseInsertError
            }
        } catch {
            print("insertion failed: \(error)")
            throw error
        }
    }
    
    func deleteFlowFromDatabase(flow: FlowRow) {
        
        guard let db = self.connection else {
            print("No db connection available")
            return
        }
        
        let del = cashFlowsTable.filter(idColumn == flow.id)
        do {
            try db.run(del.delete())
        } catch {
            print("Unable to delete row")
            print(error)
        }
    }
    
    func selectAllCashFlows() -> [FlowRow] {
        
        guard let db = self.connection else {
            print("No db connection available")
            return []
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        do {
            for flow in try db.prepare(cashFlowsTable) {
                
                print(flow)
                
                let rowId = flow[idColumn]
                let dateString = flow[dateColumn]
                let desc = flow[descriptionColumn]
                let flowAm = flow[flowAmountColumn]
                
                if let dateValue = dateFormatter.date(from: dateString) {
                    let row = FlowRow(id: rowId, date: dateValue, description: desc, total: 0.0, flowAmount: flowAm)
                    rows.append(row)
                } else {
                    //If the date can't be converted properly, just use the current date
                    let row = FlowRow(id: rowId, date: Date(), description: desc, total: 0.0, flowAmount: flowAm)
                    rows.append(row)
                }
            }
        } catch {
            print("Unable to get cash flows")
            print(error)
        }
        
        self.sortRows()
        
        return rows
    }
    
    func sortRows() {
        //Sort the rows in place according to date
        rows.sort() {
            (flowRow1, flowRow2) in
            
            if flowRow1.unixTimeStamp < flowRow2.unixTimeStamp {
                return true
            } else {
                return false
            }
        }
    }
    
    func createCashFlowsTableIfNotExists() {
        
        guard let db = self.connection else {
            print("No db connection available")
            return
        }
        
        let exists = UserDefaults.standard.bool(forKey: "isCashTablePresent")
        
        if !exists {
           
            do {
                try db.run(cashFlowsTable.create { t in     // CREATE TABLE "cashFlows" (
                    t.column(idColumn, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                    t.column(dateColumn)
                    t.column(descriptionColumn)
                    t.column(flowAmountColumn)
                })
                UserDefaults.standard.set(true, forKey: "isCashTablePresent")
            } catch  {
                print("Unable to create table")
                print(error)
            }
        }
    }
    
}//end class
