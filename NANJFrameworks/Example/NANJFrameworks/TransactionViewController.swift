//
//  TransactionViewController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 5/6/18.
//  Copyright © 2018 NANJ. All rights reserved.
//

import UIKit
import NANJFrameworks

class TransactionViewController: BaseViewController {
    
    let cellIdentifier:String = "Cell"
    var transactions: [NANJTransaction] = []
    var currentWallet: NANJWallet?
    
    @IBOutlet weak var tbvTransaction: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbvTransaction.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
    }

    func loadTransactions() {
        self.showLoading()
        self.currentWallet = NANJWalletManager.shared.getCurrentWallet()
        self.currentWallet?.delegate = self
        self.currentWallet?.getTransactionList(page: 1, offset: 20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) 
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


extension TransactionViewController: NANJWalletDelegate {
    func didGetTransactionList(transactions: Array<NANJTransaction>?) {
        self.hideLoading()
        if transactions != nil {
            self.transactions = transactions!
            self.tbvTransaction.reloadData()
        } else {
            self.showMessage("Get transaction fail.")
        }
    }
}
