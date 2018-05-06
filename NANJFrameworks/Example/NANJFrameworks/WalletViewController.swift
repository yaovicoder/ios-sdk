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

class WalletViewController: BaseViewController, NANJWalletManagerDelegate, NANJWalletDelegate {
    
    @IBOutlet weak var imvQRCode: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblCoin: UILabel!
    @IBOutlet weak var lblCoinETH: UILabel!
    
    fileprivate var currentWallet: NANJWallet?
    
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
        self.currentWallet = NANJWalletManager.shared.getCurrentWallet()
        self.currentWallet?.delegate = self
        if let wallet = self.currentWallet {
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
        self.currentWallet?.getAmountNANJ()
        self.currentWallet?.getAmountETH()
    }
    
    
    //MARK: - NANJWalletManagerDelegate

    
    
    //MARK: = NANJWalletDelegate
    func didSendNANJCompleted(transaction: NANJTransaction?) {
        
    }
    
    func didGetTransactionList(transactions: Array<NANJTransaction>?) {
        
    }
    
    func didGetAmountNANJ(wallet: NANJWallet, amount: String, error: Error?) {
        self.lblCoin.text = String(format: "%@ (ESNJCOIN)", amount)
    }
    
    func didGetAmountETH(wallet: NANJWallet, amount: String, error: Error?) {
        self.lblCoinETH.text = String(format: "%@ (ETH)", amount)
    }
}
