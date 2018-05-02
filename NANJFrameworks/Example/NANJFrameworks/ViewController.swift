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
        if let __wallet: NANJWallet = NANJWalletManager.shared.getCurrentWallet() {
            if NANJWalletManager.shared.removeWallet(wallet: __wallet) {
                print("Remove wallet success")
            } else {
                print("Remove wallet failed.")
            }
        }
    }
    
    @IBAction func onClickExportKeystore(_ sender: Any) {
        if let __wallet: NANJWallet = NANJWalletManager.shared.getCurrentWallet() {
            self.openExportKeystore(wallet: __wallet)
        }
    }
    
    @IBAction func onClickCopyPrivateKey(_ sender: Any) {
        if let wallet = NANJWalletManager.shared.getCurrentWallet() {
            self.showLoading()
            NANJWalletManager.shared.exportPrivateKey(wallet: wallet)
        }
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
        self.openCreateWallet()
    }
    
    @IBAction func onClickImportWallet(_ sender: Any) {
        self.openImportOption()
    }
    
    @IBAction func onClickListWalllet(_ sender: Any) {
        //Push to WalletListController
    }
    
    @IBAction func onClickSendNANJ(_ sender: Any) {
        NANJWalletManager.shared.scanAddressFromNFC()

    }
    
    //MARK: - NANJWalletManagerDelegate
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        self.hideLoading()
        if let __wallet = wallet {
            self.showMessage("Created wallet: " + __wallet.address)
        } else {
            self.showMessage("Created wallet fail.")
        }
    }
    
    func didImportWallet(wallet: NANJWallet?, error: Error?) {
        print("didImportWallet")
        self.hideLoading()
        if let __wallet = wallet {
            self.showMessage("Imported wallet: " + __wallet.address)
        } else {
            self.showMessage( error?.localizedDescription ?? "Import wallet fail.")
        }
    }
    
    func didExportPrivatekey(wallet: NANJWallet, privateKey: String?, error: Error?) {
        self.hideLoading()
        if let key = privateKey {
            self.shareActivity(str: key)
        } else {
            self.showMessage("Export private key error")
        }
    }
    
    func didExportKeystore(wallet: NANJWallet, keyStore: String?, error: Error?) {
        self.hideLoading()
        if let key = keyStore {
            self.shareActivity(str: key)
        } else {
            self.showMessage("Export key store error")
        }
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
    
    //MARK: - Private method
    fileprivate func openImportOption() {
        let actionSheet: UIAlertController = UIAlertController(title: "Select import type", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancel)
        
        let keystore = UIAlertAction(title: "JSON File", style: .default)
        { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ImportJSONViewController")
            self.navigationController?.pushViewController(controller, animated: true)
        }
        actionSheet.addAction(keystore)
        
        let privateKey = UIAlertAction(title: "Private Key", style: .default)
        { _ in
            self.openImportPrivateKey()
        }
        actionSheet.addAction(privateKey)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func openCreateWallet() {
        let alert = UIAlertController(title: "Input password", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let __text = textField?.text {
                if __text.count > 0 {
                    self.showLoading()
                    NANJWalletManager.shared.createWallet(password: __text)
                }
            }
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    fileprivate func openImportPrivateKey() {
        let alert = UIAlertController(title: "Input private key", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let __text = textField?.text {
                if __text.count > 0 {
                    self.showLoading()
                    NANJWalletManager.shared.importWallet(privateKey: __text)
                }
            }
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in

        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func openExportKeystore(wallet: NANJWallet) {
        let alert = UIAlertController(title: "Input password", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let __text = textField?.text {
                if __text.count > 0 {
                    self.showLoading()
                    NANJWalletManager.shared.exportKeystore(wallet: wallet, password: __text)
                }
            }
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func shareActivity(str: String) {
        if str.count == 0 {
            return
        }
        let activity: UIActivityViewController = UIActivityViewController(activityItems: [str], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }

}

