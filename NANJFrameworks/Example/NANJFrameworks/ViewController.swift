//
//  ViewController.swift
//  NANJFrameworks
//
//  Created by AnhKu on 04/16/2018.
//  Copyright (c) 2018 AnhKu. All rights reserved.
//

import UIKit
import NANJFrameworks

class ViewController: BaseViewController, NANJWalletManagerDelegate, NANJWalletDelegate {
    @IBOutlet weak var viewWallet: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWallet.layer.cornerRadius = 6
        NANJWalletManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let wallet = NANJWalletManager.shared.getCurrentWallet() {
            self.lblName.text = "Wallet name"
            self.lblAddress.text = wallet.address
        } else {
            self.lblName.text = "Wallet name"
            self.lblAddress.text = "0x"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action with current wallet
    @IBAction func onClickRemoveWallet(_ sender: Any) {
        
    }
    
    @IBAction func onClickExportKeystore(_ sender: Any) {
        
    }
    
    @IBAction func onClickCopyPrivateKey(_ sender: Any) {
        
    }
    
    @IBAction func onClickCopyAddress(_ sender: Any) {
        if (self.lblAddress.text?.count ?? 0) > 2 {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = self.lblAddress.text
            self.showMessage("Copied: " + self.lblAddress.text!)
        } else {
            self.showMessage("No address")
        }
    }
    
    //MARK: - Action Wallet
    @IBAction func onClickCreateWallet(_ sender: Any) {
        self.showLoading()
        NANJWalletManager.shared.createWallet(password: "longlee")
    }
    
    @IBAction func onClickImportWallet(_ sender: Any) {
        
    }
    
    @IBAction func onClickListWalllet(_ sender: Any) {
        //Push to WalletListController
    }
    
    
    //MARK: - NANJWalletManagerDelegate
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        self.hideLoading()
        if wallet != nil {
            self.showMessage("Wallet create success!")
            self.lblAddress.text = wallet?.address
        } else {
            self.showMessage("Wallet create fail.")
        }
    }
    
    func didImportWallet(wallet: NANJWallet?, error: Error?) {
        print("didImportWallet")
    }
    
    func didGetWalletList(wallets: Array<NANJWallet?>, error: Error?) {
        print("didGetWalletList")
    }
    
    func didGetWalletFromQRCode(wallet: NANJWallet?) {
        print("didGetWalletFromQRCode")
    }
    
    func didGetNANJRate(rate: Double) {
        print("didGetNANJRate")
    }
    
    //MARK: - SendNANJ Delegate
    func didSendNANJCompleted(transaction: NANJTransaction?) {
        print("didGetTransactionList")
    }
    
    func didGetTransactionList(transactions: Array<NANJTransaction>?) {
        print("didGetTransactionList")
    }
    

}

