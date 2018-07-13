//
//  WalletListCell.swift
//  NANJFrameworks_Example
//
//  Created by MinaWorks on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NANJFrameworks

class WalletListCell: UITableViewCell {

    @IBOutlet weak var lblWalletName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var wallet: NANJWallet? {
        didSet {
            self.lblAddress.text = wallet?.address
        }
    }
    
    var complete: ((_ wallet: NANJWallet) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickMore(_ sender: Any) {
        guard let __wallet = self.wallet, let __complete = self.complete else {
            return
        }
        __complete(__wallet)
    }
    
}
