//
//  CashFlowTableViewCell.swift
//  Simple Cash Flow
//
//  Created by Josh Hawthorne on 6/20/18.
//  Copyright © 2018 Hawthorne Applications. All rights reserved.
//

import UIKit

class CashFlowTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
