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
    @IBOutlet weak var lblFee: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
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
        self.lblTitle.text = transaction.message ?? "<No Message>"
        if let address: String = NANJWalletManager.shared.getCurrentWallet()?.address {
            if address.lowercased() == transaction.to?.lowercased() {
                // Received
                self.lblTo.text = String(format: "From: %@", transaction.from ?? "")
                self.lblAmount.text = String(format: "+%@ %@", transaction.value ?? 0, transaction.tokenSymbol ?? "")
                self.lblAmount.textColor = UIColor(hexString: "009051", transparency: 0.8)
                self.lblFee.isHidden = true
                self.imvIcon.image = UIImage(named: "transaction_received")
            } else {
                //Send
                self.lblTo.text = String(format: "To: %@", transaction.to ?? "")
                self.lblAmount.textColor = UIColor.red
                self.lblFee.textColor = UIColor.red
                self.lblAmount.text = String(format: "-%@ %@", transaction.value ?? 0, transaction.tokenSymbol ?? "")
                self.lblFee.isHidden = false
                self.lblFee.text = String(format: "Fee: -%@ %@", transaction.txFee ?? 0, transaction.tokenSymbol ?? "")
                self.imvIcon.image = UIImage(named: "transaction_sent")
            }
            if let timeStamp = transaction.timestamp {
               self.lblTime.text  = DateCommon.convertTimestampToStringWith(Double(timeStamp))
            }
        }
    }

}
