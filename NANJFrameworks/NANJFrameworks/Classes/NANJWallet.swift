//
//  NANJWallet.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

public protocol NANJWalletDelegate {
    
    /// Callback Transaction when send NANJ completed.
    ///
    /// - Parameter transaction: transaction success.
    func didSendNANJCompleted(transaction: NANJTransaction?)
    
    /// Callback list Transaction when get completed.
    ///
    /// - Parameter transactions: list Transaction.
    func didGetTransactionList(transactions: Array<NANJTransaction>?)
}

public class NANJWallet: NSObject, NANJQRCodeDelegate, NANJNFCDelegate {
    
    public var delegate: NANJWalletDelegate?
    
    public var address: String = ""
    public var name: String?
    
    var amountNANJ: Double = 0.0
    var amountETH: Double = 0.0
    
    //
    fileprivate var etherWallet: Wallet?
    
    /// Send NAJI coins to other wallet
    ///
    /// - Parameters:
    ///   - address: wallet target
    ///   - amouth: the number of coin you want to transfer
    public func sendNANJ(with address: String, amouth: Double) {
        //return by delegate
        
    }
    
    
    /// Send NAJI coins to other wallet that you just scaned QR code
    ///
    /// - Parameters:
    ///   - amouth: the number of coin you want to transfer
    ///   - controller: your view controller
    public func sendNANJWithQRCode(amouth: Double, fromController controller: UIViewController) {
        //return by delegate
        
    }
    
    
    /// Send NAJI coins to other wallet that you connected by NFC method
    ///
    /// - Parameters:
    ///   - amouth: the number of coin you want to transfer
    ///   - controller: your view controller
    public func sendNANJWithNFC(amouth: Double, fromController controller: UIViewController) {
        //return by delegate
        
    }
    
    
    /// Get your NAJI amount
    ///
    /// - Returns: your NAJI coins
    public func getAmountNANJ() -> Double {
        return self.amountNANJ
    }
    
    
    /// Get your ETH amount
    ///
    /// - Returns: your ETH coins
    public func getAmountETH() -> Double {
        return self.amountETH
    }
    
    
    /// Edit your wallet name. It only store in your device.
    ///
    /// - Parameter name: a new name you want.
    /// - Returns: if edit successful return true and opposite.
    public func editName(name: String) -> Bool{
        return false
    }
    
    
    /// After get transactions on async function
    /// return list transactions in callback delegate.
    public func getTransactionList() {
        //Return by delegate
        //Ex
        self.delegate?.didGetTransactionList(transactions: nil)
    }
    
    
    /// Get URL Wallet on Etherscan
    ///
    /// - Returns: URL Ether
    public func getURLOnEtherscan() -> URL? {
        
        return nil
    }
    
    public func enableWallet() {
        EtherKeystore.shared.recentlyUsedWallet = self.etherWallet
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
    
    //MARK: - Support method
    func addEtherWallet(wallet: Wallet) {
        self.etherWallet = wallet
    }
    
    func getEtherWallet() -> Wallet? {
        return self.etherWallet
    }
}
