//
//  TransactionDetailViewController.swift
//  NANJFrameworks_Example
//
//  Created by MinaWorks on 5/13/18.
//  Copyright © 2018 NANJ. All rights reserved.
//

import UIKit
import NANJFrameworks

class TransactionDetailViewController: BaseViewController {
    
    @IBOutlet weak var btnCoin: UIButton!
    
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var btnAddress: UIButton!
    
    @IBOutlet weak var btnTxHash: UIButton!
    
    @IBOutlet weak var btnFee: UIButton!
    @IBOutlet weak var btnConfirmNumber: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    var transaction: NANJTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Transaction detail"
        self.loadDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func loadDetail() {
        if let address: String = NANJWalletManager.shared.getCurrentWallet()?.address {
            if address.lowercased() == transaction.to?.lowercased() {
                // Received
                self.btnAddress.setTitle(String(format: "%@", transaction.from ?? ""), for: .normal)
                self.btnCoin.setTitleColor(UIColor(hexString: "009051", transparency: 0.8), for: .normal)
                self.btnCoin.setTitle(String(format: "  +%@ %@", transaction.value ?? 0, transaction.tokenSymbol ?? ""), for: .normal)
                self.btnCoin.setImage(UIImage(named: "transaction_received"), for: .normal)
                self.lblSender.text = "Sender"
            } else {
                //Send
                self.btnAddress.setTitle(String(format: "%@", transaction.to ?? ""), for: .normal)
                self.btnCoin.setTitleColor(UIColor.red, for: .normal)
                self.btnCoin.setTitle(String(format: "  -%@ %@", transaction.value ?? 0, transaction.tokenSymbol ?? ""), for: .normal)
                self.lblSender.text = "Recipient"
                self.btnCoin.setImage(UIImage(named: "transaction_sent"), for: .normal)
            }
        }
        
        self.btnTxHash.setTitle(self.transaction.txHash, for: .normal)    
        
        if let timeStamp = self.transaction.timestamp {
            self.btnDate.setTitle(DateCommon.convertTimestampToStringWith(Double(timeStamp)), for: .normal)
        }
        self.btnFee.setTitle(String(format: "%@ NANJ", self.transaction.txFee ?? ""), for: .normal)
        
        self.lblMessage.text = transaction.message ?? "<No Message>"
        
    }
    
    //MARK:- Action
    
    @IBAction func onClickCopyAddress(_ sender: Any) {
        if let str = self.btnAddress.titleLabel?.text {
            self.openCopyString(string: str)
        }
    }
    
    @IBAction func onClickCopyTxHash(_ sender: Any) {
        if let str = self.btnTxHash.titleLabel?.text {
            self.openCopyString(string: str)
        }
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if let str = self.btnConfirmNumber.titleLabel?.text {
            self.openCopyString(string: str)
        }
    }
    
    @IBAction func onClickMoreDetail(_ sender: Any) {
        if let __url = self.transaction.getURLOnEtherscan() {
            UIApplication.shared.open(__url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK:- Private Function
    fileprivate func openCopyString(string: String) {
        let actionSheet: UIAlertController = UIAlertController(title: string, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        actionSheet.addAction(cancel)
        
        let copy = UIAlertAction(title: "Copy", style: .default)
        { _ in
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = string
        }
        actionSheet.addAction(copy)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}
