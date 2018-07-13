//
//  TransactionListCell.swift
//  NANJFrameworks_Example
//
//  Created by MinaWorks on 5/13/18.
//  Copyright © 2018 NANJ. All rights reserved.
//

import UIKit
import NANJFrameworks

class TransactionListCell: UITableViewCell {

    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellWith(transaction: NANJTransaction) {
        self.lblTo.text = ""
        if let address: String = NANJWalletManager.shared.getCurrentWallet()?.address {
            if address.lowercased() == transaction.to?.lowercased() {
                // Received
                self.lblTo.text = String(format: "From: %@", transaction.from ?? "")
                self.lblAmount.text = String(format: "+%@ %@", transaction.value ?? 0, "ESNJ")
                self.lblAmount.textColor = UIColor(hexString: "009051", transparency: 0.8)
                self.imvIcon.image = UIImage(named: "transaction_received")
            } else {
                //Send
                self.lblTo.text = String(format: "To: %@", transaction.to ?? "")
                self.lblAmount.textColor = UIColor.red
                self.lblAmount.text = String(format: "-%@ %@", transaction.value ?? 0, "ESNJ")
                self.imvIcon.image = UIImage(named: "transaction_sent")
            }
        }
    }

}
