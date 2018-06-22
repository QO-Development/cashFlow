//
//  FlowRow.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import Foundation

enum RowMode {
    case Edit
    case Add
}

enum FlowType {
    case Inflow
    case Outflow
}

struct FlowRow {
    
    var type: FlowType {
        if self.flowAmount < 0 {
            return .Outflow
        } else {
            return .Inflow
        }
    }
    
    var id : Int64
    
    var unixTimeStamp: Double {
        return self.date.timeIntervalSince1970
    }
    
    var shortDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self.date)
    }
    
    var longDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self.date)
    }
    
    var date: Date
    var description: String
    var total: Double 
    var flowAmount: Double
    
}
