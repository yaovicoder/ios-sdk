//
//  NANJWallet.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

public protocol NANJWalletDelegate {
    func didSendNANJCompleted(transaction: NANJTransaction?)
    func didGetTransactionList(transactions: Array<NANJTransaction>?)
}

public class NANJWallet: NSObject, NANJQRCodeDelegate, NANJNFCDelegate {
    
    public var delegate: NANJWalletDelegate?
    
    public var addrres: String! = ""
    public var name: String?
    
    var amountNANJ: Double = 0.0
    var amountETH: Double = 0.0
    var isEnable: Bool = false
    
    private var privateKey: String! = ""
    
    public func sendNANJ(with address: String, amouth: Double) {
        //return by delegate
        
    }
    
    public func sendNANJWithQRCode(amouth: Double, fromController controller: UIViewController) {
        //return by delegate
        
    }
    
    public func sendNANJWithNFC(amouth: Double, fromController controller: UIViewController) {
        //return by delegate
        
    }
    
    public func getAmountNANJ() -> Double {
        return self.amountNANJ
    }
    
    public func getAmountETH() -> Double {
        return self.amountETH
    }
    
    public func editName(name: String) -> Bool{
        return false
    }
    
    public func getTransactionList() {
        //Return by delegate
        //Ex
        self.delegate?.didGetTransactionList(transactions: nil)
    }
    
    public func getURLOnEtherscan() -> URL? {
        
        return nil
    }
    
    //MARK - NANJQRCodeDelegate, NANJNFCDelegate
    func didScanQRCode(address: String) {
        //Received address from QRCode
    }
    
    func didScanNFC(address: String) {
        //Received address from NFC
    }
    
    func didCloseScan() {
        
    }
}
