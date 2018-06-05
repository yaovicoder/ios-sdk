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
    fileprivate var walletManager: NANJWalletManager = NANJWalletManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.walletManager.delegate = self
        if self.lblAddress.text != "Initializing ..." {
            self.loadCurrentWallet()
            self.loadBalance()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onClickListWallet(_ sender: Any) {
        let listVC: WalletListController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletListController") as! WalletListController
        listVC.walletVC = self
        self.navigationController?.pushViewController(listVC, animated: true)
    }
    
    fileprivate func loadCurrentWallet() {
        self.currentWallet = self.walletManager.getCurrentWallet()
        self.currentWallet?.delegate = self
        self.updateLayout(self.currentWallet)
    }
    
    fileprivate func loadBalance() {
        self.currentWallet?.getAmountNANJ()
        //self.currentWallet?.getAmountETH()
    }
    
    fileprivate func updateLayout(_ wallet: NANJWallet?) {
        if let __wallet = wallet {
            self.lblAddress.text = __wallet.address
            self.imvQRCode.backgroundColor = UIColor.white
            self.imvQRCode.sd_setImage(with: URL(string: String(format: "http://api.qrserver.com/v1/create-qr-code/?data=%@", __wallet.address)), completed: nil)
        } else {
            self.lblAddress.text = ""
            self.imvQRCode.backgroundColor = UIColor.lightGray
            self.imvQRCode.image = nil
        }
    }
    
    
    //MARK: - NANJWalletManagerDelegate
    func didCreatingWallet(wallet: NANJWallet?) {
        print("WalletViewController didCreatingWallet")
        self.lblAddress.text = "Initializing ..."
    }

    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        print("WalletViewController didCreateWallet")
        if let __wallet = wallet {
            if self.walletManager.getCurrentWallet() == nil {
                __wallet.enableWallet()
                _ = self.walletManager.enableWallet(wallet: __wallet)
                self.currentWallet = __wallet
                self.updateLayout(__wallet)
                self.loadBalance()
            }
            self.showMessage("Created wallet: " + __wallet.address)
        } else {
            self.showMessage("Created wallet fail.")
        }
    }
    
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
