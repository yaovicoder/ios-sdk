//
//  WalletViewController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 5/6/18.
//  Copyright © 2018 NANJ. All rights reserved.
//

import UIKit
import NANJFrameworks
import SDWebImage

class WalletViewController: BaseViewController, NANJWalletManagerDelegate {
    
    @IBOutlet weak var imvQRCode: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblCoin: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NANJWalletManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCurrentWallet()
        self.loadBalance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func loadCurrentWallet() {
        if let wallet = NANJWalletManager.shared.getCurrentWallet() {
            self.lblAddress.text = wallet.address
            self.imvQRCode.backgroundColor = UIColor.white
            self.imvQRCode.sd_setImage(with: URL(string: String(format: "http://api.qrserver.com/v1/create-qr-code/?data=%@", wallet.address)), completed: nil)
        } else {
            self.lblAddress.text = ""
            self.imvQRCode.backgroundColor = UIColor.lightGray
            self.imvQRCode.image = nil
        }
    }
    
    fileprivate func loadBalance() {
        
    }
    
}
