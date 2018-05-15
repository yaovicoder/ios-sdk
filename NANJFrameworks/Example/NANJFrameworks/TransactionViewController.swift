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
    
    let cellIdentifier: String = "TransactionListCell"
    var transactions: [NANJTransaction] = []
    var currentWallet: NANJWallet?
    
    private let refreshControl = UIRefreshControl()
    
    fileprivate var isLoading: Bool = false
    
    @IBOutlet weak var tbvTransaction: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbvTransaction.tableFooterView = UIView()
        self.tbvTransaction.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadTransactions), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
    }

    @objc func loadTransactions() {
        self.refreshControl.endRefreshing()
        if self.isLoading {
            return;
        }
        self.isLoading = true;
        self.showLoading()
        self.currentWallet = NANJWalletManager.shared.getCurrentWallet()
        self.currentWallet?.delegate = self
        self.currentWallet?.getTransactionList(page: 1, offset: 2000)
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
        let cell:TransactionListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TransactionListCell
        cell.updateCellWith(transaction: self.transactions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let transaction: NANJTransaction = self.transactions[safe: indexPath.row] {
            let controller: TransactionDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
            controller.transaction = transaction
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


extension TransactionViewController: NANJWalletDelegate {
    func didGetTransactionList(transactions: Array<NANJTransaction>?) {
        self.isLoading = false
        self.hideLoading()
        if transactions != nil {
            self.transactions = transactions!
            self.tbvTransaction.reloadData()
        } else {
            self.showMessage("Get transaction fail.")
        }
    }
}
