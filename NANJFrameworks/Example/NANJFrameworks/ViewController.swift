//
//  ViewController.swift
//  NANJFrameworks
//
//  Created by AnhKu on 04/16/2018.
//  Copyright (c) 2018 AnhKu. All rights reserved.
//

import UIKit
import NANJFrameworks

class ViewController: UIViewController, NANJWalletManagerDelegate, NANJWalletDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let walletManager: NANJWalletManager = NANJWalletManager.shared
        walletManager.delegate = self
        walletManager.createWallet()
        
        let wallet: NANJWallet = NANJWallet()
        wallet.delegate = self
        wallet.getTransactionList()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - NANJWalletManagerDelegate
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        print("didCreateWallet")
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
    
    //MARK: -
    func didSendNANJCompleted(transaction: NANJTransaction?) {
        print("didGetTransactionList")
    }
    
    func didGetTransactionList(transactions: Array<NANJTransaction>?) {
        print("didGetTransactionList")
    }
    
    //MARK: - Action
    
    @IBAction func onClickScanQRCode(_ sender: UIButton) {

    }
    
    @IBAction func onClickScanNFC(_ sender: UIButton) {

    }
    
}

