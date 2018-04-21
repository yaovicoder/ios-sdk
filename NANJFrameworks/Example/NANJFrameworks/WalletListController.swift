
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
        
        self.loadWallets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWallets() {
        self.showLoading()
        NANJWalletManager.shared.delegate = self
        NANJWalletManager.shared.getWalletList()
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
