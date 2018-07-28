
//
//  WalletListController.swift
//  NANJFrameworks_Example
//
//  Created by MinaWorks on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NANJFrameworks

class WalletListController: BaseViewController, UITableViewDelegate, UITableViewDataSource, NANJWalletManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var walletVC: WalletViewController?
    
    fileprivate var wallets: Array<NANJWallet> = []
    fileprivate var walletManager: NANJWalletManager = NANJWalletManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.walletManager.delegate = self
        self.loadWallets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {

    }
    
    func loadWallets() {
        self.showLoading()
        self.walletManager.getWalletList()
    }
    
    @IBAction func onClickCreateWallet(_ sender: Any) {
        //Get current password
        let __password: String? = (UserDefaults.standard.object(forKey: "user_password") as? String) ?? nil
        if (__password != nil) {
            self.showLoading()
            self.walletManager.createWallet(password: __password!)
        } else {
            self.openCreateWallet()
        }
    }
    
    @IBAction func onClickImportWallet(_ sender: Any) {
        self.openImportOption()
    }
    
    //MARK: - Private method
    fileprivate func openImportOption() {
        let actionSheet: UIAlertController = UIAlertController(title: "Select import type", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in

        }
        actionSheet.addAction(cancel)
        
        let keystore = UIAlertAction(title: "Keystore", style: .default)
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
                    self.walletManager.importWallet(privateKey: __text)
                }
            }
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
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
                    self.walletManager.createWallet(password: __text)
                }
            }
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func openMoreWallet(wallet: NANJWallet) {
        let actionSheet: UIAlertController = UIAlertController(title: "Address", message: wallet.address, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        actionSheet.addAction(cancel)
        
        let copy = UIAlertAction(title: "Copy address", style: .default)
        { [weak self] _ in
            guard let `self` = self else {return}
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = wallet.address
            self.showMessage("Copied: " + wallet.address)
        }
        actionSheet.addAction(copy)
        
        let keyStore = UIAlertAction(title: "Backup Keystore", style: .default)
        { [weak self] _ in
            guard let `self` = self else {return}
            self.openExportKeystore(wallet: wallet)
        }
        actionSheet.addAction(keyStore)
        
        let privateKey = UIAlertAction(title: "Export private key", style: .default)
        {[weak self] _ in
            guard let `self` = self else {return}
            self.showLoading()
            self.walletManager.exportPrivateKey(wallet: wallet)
        }
        actionSheet.addAction(privateKey)
        
        let remove = UIAlertAction(title: "Remove wallet", style: .destructive)
        {[weak self] _ in
            guard let `self` = self else {return}
            self.showLoading()
            DispatchQueue.main.async {
                if self.walletManager.removeWallet(wallet: wallet) {
                    self.hideLoading()
                    self.loadWallets()
                } else {
                    self.hideLoading()
                    self.showMessage("Remove wallet failed.")
                }
            }
        }
        actionSheet.addAction(remove)
        
        self.present(actionSheet, animated: true, completion: nil)
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
                    self.walletManager.exportKeystore(wallet: wallet, password: __text)
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
    
    //MARK: - NANJManagerDelegate
    func didGetWalletList(wallets: [NANJWallet]?, error: Error?) {
        self.hideLoading()
        guard let __wallets = wallets else {
            return
        }
        self.wallets = __wallets
        self.tableView.reloadData()
    }
    
    func didCreatingWallet(wallet: NANJWallet?) {
        self.hideLoading()
        if let __wallet = wallet {
            self.walletVC?.didCreatingWallet(wallet: __wallet)
            self.showMessage("Initializing NANJ wallet from ETH wallet: " + __wallet.addressETH)
        } else {
            self.showMessage("Created wallet fail.")
        }
    }
    
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        self.hideLoading()
        if let __wallet = wallet {
            if self.walletManager.getCurrentWallet() == nil {
                __wallet.enableWallet()
            }
            self.showMessage("Created wallet: " + __wallet.address)
            self.loadWallets()
        } else {
            self.showMessage("Created wallet fail.")
        }
    }
    
    func didImportWallet(wallet: NANJWallet?, error: Error?) {
        self.hideLoading()
        if let __wallet = wallet {
            if self.walletManager.getCurrentWallet() == nil {
                __wallet.enableWallet()
            }
            self.showMessage("Imported wallet: " + __wallet.address)
            self.loadWallets()
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
    
    
    //MARK: - Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WalletListCell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as! WalletListCell
        let wallet: NANJWallet = self.wallets[indexPath.row]
        cell.wallet = wallet
        cell.complete = {[weak self] wallet in
            guard let `self` = self else { return }
            self.openMoreWallet(wallet: wallet)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet: NANJWallet = self.wallets[indexPath.row]
        if self.walletManager.enableWallet(wallet: wallet) {
            self.showMessage("Active wallet: " + wallet.address)
        } else {
            self.showMessage("Coun't active wallet")
        }
    }
    
}
