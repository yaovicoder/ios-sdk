//
//  WalletViewController.swift
//  NANJFrameworks_Example
//
//  Created by MinaWorks on 5/6/18.
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
    
    fileprivate var balance: Double?
    fileprivate var nanjRate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.walletManager.delegate = self
        if self.walletManager.getCurrentWallet() != nil {
            self.loadCurrentWallet()
            self.loadBalance()
            self.walletManager.getNANJRate()
        }
//        if self.lblAddress.text != "Initializing ..." {
//            self.loadCurrentWallet()
//            self.loadBalance()
//        }
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
    
    @IBAction func onClickChangeCoin(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "Select Coin", message: nil, preferredStyle: .actionSheet)
        
        if let listERC20 = self.walletManager.getListERC20Support() {
            listERC20.forEach { obj in
                let action = UIAlertAction(title: obj.getName(), style: .default, handler: { action in
                    if (NANJWalletManager.shared.setCurrentERC20Support(obj.getERC20Id())) {
                        self.showMessage("Change \(obj.getName()) successfully.")
                        self.loadCurrentWallet()
                        self.loadBalance()
                    } else {
                        self.showMessage("Change \(obj.getName()) failed.")
                    }
                })
                alert.addAction(action)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Private method
    
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
    
    fileprivate func updateYEN() {
        guard let rate = self.nanjRate, let amount = self.balance else {
            return
        }
        let jpy = rate*amount;
        if jpy > 0 {
            self.lblCoinETH.text = String(format: "%0.2f (JPY)", jpy)
        } else {
            self.lblCoinETH.text = String(format: "0 (JPY)", jpy)
        }
    }
    
    
    //MARK: - NANJWalletManagerDelegate
    func didCreatingWallet(wallet: NANJWallet?) {
        if self.walletManager.getCurrentWallet() == nil {
            self.lblAddress.text = "Initializing ..."
        }
    }

    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
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
    
    func didGetNANJRate(rate: Double) {
        self.nanjRate = rate
        self.updateYEN()
    }
    
    //MARK: = NANJWalletDelegate
    func didSendNANJCompleted(transaction: NANJTransaction?) {
        
    }
    
    func didGetTransactionList(transactions: Array<NANJTransaction>?) {
        
    }
    
    func didGetAmountNANJ(wallet: NANJWallet, amount: Double, error: Error?) {
        self.balance = amount
        self.updateYEN()
        
        self.lblCoin.text = String(format: "%0.3f (\(self.walletManager.getCurrentERC20Support()?.getName() ?? ""))", amount)
    }
    
    func didGetAmountETH(wallet: NANJWallet, amount: String, error: Error?) {
        self.lblCoinETH.text = String(format: "%@ (ETH)", amount)
    }
}
