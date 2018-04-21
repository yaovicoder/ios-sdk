//
//  WalletListCell.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class WalletListCell: UITableViewCell {

    @IBOutlet weak var lblWalletName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
