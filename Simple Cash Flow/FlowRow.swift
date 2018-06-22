//
//  FlowRow.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import Foundation

enum FlowType {
    case Inflow
    case Outflow
}

struct FlowRow {
    var type: FlowType {
        if self.total < 0 {
            return .Outflow
        } else {
            return .Inflow
        }
    }
    
    var id : Int64
    var date: String
    var description: String
    var total: Double 
    var flowAmount: Double 
}
