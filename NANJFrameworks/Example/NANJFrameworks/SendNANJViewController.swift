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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickQRCode(_ sender: Any) {
        //Open QRCode
    }
    
    @IBAction func onClickNFC(_ sender: Any) {
        //Open NFC
        
    }
    
    @IBAction func onClickSendNANJ(_ sender: Any) {
        //Send NANJ
        if !self.validateInput() {
            return
        }
        
        
        
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
