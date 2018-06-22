//
//  AddRowProtocol.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import Foundation

protocol AddRowDelegate {
    func UpdateNewRowData(id: Int64, date: String, description: String, flow: Double, total: Double)
} 
