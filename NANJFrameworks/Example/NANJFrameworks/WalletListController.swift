
//
//  WalletListController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NANJFrameworks

class WalletListController: BaseViewController, UITableViewDelegate, UITableViewDataSource, NANJWalletManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var wallets: Array<NANJWallet> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        NANJWalletManager.shared.delegate = self
        
        self.loadWallets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWallets() {
        self.showLoading()
        NANJWalletManager.shared.getWalletList()
    }
    
    @IBAction func onClickCreateWallet(_ sender: Any) {
        //Get current password
        let __password: String? = (UserDefaults.standard.object(forKey: "user_password") as? String) ?? nil
        
        if (__password != nil) {
            self.showLoading()
            NANJWalletManager.shared.createWallet(password: __password!)
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
            print("Cancel")
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
                    NANJWalletManager.shared.importWallet(privateKey: __text)
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
                    NANJWalletManager.shared.createWallet(password: __text)
                }
            }
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //NANJManagerDelegate
    func didGetWalletList(wallets: [NANJWallet]?, error: Error?) {
        self.hideLoading()
        guard let __wallets = wallets else {
            return
        }
        self.wallets = __wallets
        self.tableView.reloadData()
    }
    
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
        self.hideLoading()
        if let __wallet = wallet {
            self.showMessage("Created wallet: " + __wallet.address)
            self.loadWallets()
        } else {
            self.showMessage("Created wallet fail.")
        }
    }
    
    func didImportWallet(wallet: NANJWallet?, error: Error?) {
        print("didImportWallet")
        self.hideLoading()
        if let __wallet = wallet {
            self.showMessage("Imported wallet: " + __wallet.address)
            self.loadWallets()
        } else {
            self.showMessage( error?.localizedDescription ?? "Import wallet fail.")
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
        cell.lblAddress.text = wallet.address
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet: NANJWallet = self.wallets[indexPath.row]
        if NANJWalletManager.shared.enableWallet(wallet: wallet) {
            self.showMessage("Active wallet: " + wallet.address)
        } else {
            self.showMessage("Coun't active wallet")
        }
    }
    
}
