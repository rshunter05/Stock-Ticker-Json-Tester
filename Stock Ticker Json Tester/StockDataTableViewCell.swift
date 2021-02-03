//
//  StockDataTableViewCell.swift
//  Stock Ticker Json Tester
//
//  Created by Robert Hunter on 1/24/21.
//  Copyright © 2021 Robert Hunter. All rights reserved.
//

import UIKit

class StockDataTableViewCell: UITableViewCell {

    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var priceDiff: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
