//
//  SendNANJViewController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 5/6/18.
//  Copyright © 2018 NANJ. All rights reserved.
//

import UIKit
import NANJFrameworks

class SendNANJViewController: BaseViewController {

    @IBOutlet weak var txfAddress: UITextField!
    
    @IBOutlet weak var txfAmount: UITextField!
    
    fileprivate var nfc: NANJNFC?
    fileprivate var currentWallet: NANJWallet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.currentWallet = NANJWalletManager.shared.getCurrentWallet()
        self.currentWallet?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickQRCode(_ sender: Any) {
        //Open QRCode
    }
    
    @IBAction func onClickNFC(_ sender: Any) {
        //Open NFC
        if #available(iOS 11.0, *) {
            if self.nfc == nil {
                self.nfc = NANJNFC.init()
                self.nfc?.delegate = self
            }
            self.nfc?.startScan()
        } else {
            //iOS not support
            print("iOS not support NFC")
        }
    }
    
    @IBAction func onClickSendNANJ(_ sender: Any) {
        //Send NANJ
        if !self.validateInput() {
            return
        }
        self.showLoading()
        self.currentWallet?.sendNANJ(toAddress: self.txfAddress.text!, amount: self.txfAmount.text!)
    }
    
    
    fileprivate func validateInput() -> Bool {
        if self.txfAmount.text?.length == 0 || self.txfAddress.text?.length == 0 {
            self.showMessage("Please input data.")
            return false
        }
        if !NANJWalletManager.shared.isValidAddress(address: self.txfAddress.text){
            //Valid Ether address
            self.showMessage("Invalid address")
            return false
        }
        return true
    }
    
}

extension SendNANJViewController: NANJNFCDelegate {
    func didScanNFC(address: String?) {
        DispatchQueue.main.async {
            if let __address = address {
                self.txfAddress.text = __address
            } else {
                print("Address invalid")
            }
        }
    }
    
    func didCloseScan() {
        self.nfc = nil
    }
}

extension SendNANJViewController: NANJWalletDelegate {
    func didSendNANJCompleted(transaction: NANJTransaction?) {
        self.hideLoading()
        if transaction != nil {
            self.showMessage("Send NANJ success.")
        } else {
            self.showMessage("Send NANJ failed.")
        }
    }
}

