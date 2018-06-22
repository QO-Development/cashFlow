//
//  Database.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/21/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import Foundation
import SQLite

class Database {
    
    let id = Expression<Int64>("id")
    let date = Expression<String>("date")
    let description = Expression<String>("description")
    let flowAmount = Expression<Double>("flowAmount")
    
    let cashFlows = Table("cashFlows")
    
    
    func getConnection() -> Connection? {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("cashDatabase.sqlite")
        
        do {
            let db = try Connection(fileURL.path)
            return db
        } catch {
            print("Unable to connect to DB")
            return nil
        }
    }
    
    func deleteFlowFromDatabase(db: Connection, flow: FlowRow) {
        
        let del = cashFlows.filter(id == flow.id)
        do {
            try db.run(del.delete())
        } catch {
            print("Unable to delete row")
            print(error)
        }
        
    }
    
    func selectAllCashFlows(db: Connection) -> [FlowRow] {
        
        let cashFlows = Table("cashFlows")
        
        var rows: [FlowRow] = []
        
        do {
            for flow in try db.prepare(cashFlows) {
               // print("id: \(user[id]), email: \(user[email]), name: \(user[name])")
                print(flow)
                // id: 1, email: alice@mac.com, name: Optional("Alice")
                
                let rowId = flow[id]
                let dateValue = flow[date]
                let desc = flow[description]
                let flowAm = flow[self.flowAmount]
                
                let row = FlowRow(id: rowId, date: dateValue, description: desc, total: 0.0, flowAmount: flowAm)
                
                rows.append(row)
                
            
            }
        } catch {
            print("Unable to get cash flows")
            print(error)
        }
        
        return rows
    }
    
    func createCashFlowsTableIfNotExists(db: Connection) {
        
        let exists = UserDefaults.standard.bool(forKey: "isCashTablePresent")
        
        if !exists {
           
            do {
                try db.run(cashFlows.create { t in     // CREATE TABLE "cashFlows" (
                    t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                    t.column(date)
                    t.column(description)
                    t.column(flowAmount)
                })
                UserDefaults.standard.set(true, forKey: "isCashTablePresent")
            } catch  {
                print("Unable to create table")
                print(error)
            }
            
        }
    }
    
   
    
}
