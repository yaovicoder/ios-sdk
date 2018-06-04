//
//  ImportJSONViewController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import NANJFrameworks

class ImportJSONViewController: BaseViewController, UITextViewDelegate, UITextFieldDelegate, NANJWalletManagerDelegate {

    @IBOutlet weak var txvJSON: UITextView!
    @IBOutlet weak var txfPassword: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Import Wallet"
        self.txvJSON.layer.cornerRadius = 8
        self.txvJSON.layer.borderColor = UIColor.lightGray.cgColor
        self.txvJSON.layer.borderWidth = 0.5
        self.txvJSON.delegate = self
        self.txfPassword.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickImportJSON(_ sender: Any) {
        if self.txfPassword.text?.count ?? 0 <= 0 || self.txvJSON.text?.count ?? 0 <= 0 {
            self.showMessage("Please enter value.")
        }
        self.showLoading()
        NANJWalletManager.shared.importWallet(keyStore: self.txvJSON.text, password: self.txfPassword.text!)
        NANJWalletManager.shared.delegate = self
    }
    
    //MARK: -
    func didCreatingWallet(wallet: NANJWallet?) {
        self.hideLoading()
        if let __wallet = wallet {
            self.showMessage("Creating NANJ wallet from ETH wallet: " + __wallet.addressETH)
        } else {
            self.showMessage("Created wallet fail.")
        }
    }
    
    func didCreateWallet(wallet: NANJWallet?, error: Error?) {
         self.hideLoading()
        if let __wallet = wallet {
            self.showMessage("Created wallet: " + __wallet.address)
        } else {
            self.showMessage("Created NANJ wallet fail.")
        }

    }
    
    func didImportWallet(wallet: NANJWallet?, error: Error?) {
        self.hideLoading()
        if wallet != nil {
            self.showMessage("Imported wallet: " + (wallet?.address ?? ""))
        } else {
            self.showMessage("Import wallet fail.")
        }
    }
    

}
