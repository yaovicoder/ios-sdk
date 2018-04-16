//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

public protocol NANJWalletManagerDelegate {
    func didCreateWallet(wallet: NANJWallet?, error: Error?)
    func didImportWallet(wallet: NANJWallet?, error: Error?)
    func didGetWalletList(wallets: Array<NANJWallet?>, error: Error?)
    func didGetWalletFromQRCode(wallet: NANJWallet?)
    func didGetNANJRate(rate: Double)
}

public class NANJWalletManager: NSObject {

    public static let shared : NANJWalletManager = NANJWalletManager()
    
    public var delegate: NANJWalletManagerDelegate?
    
    /**
     Create new wallet.
     
     - returns: Wallet by NANJWalletManagerDelegate.
     */
    
    public func createWallet() {
        //Return value with delegate
        //Ex
        self.delegate?.didCreateWallet(wallet: nil, error: nil)
    }
    
    /// Import a wallet with private key and json string
    ///
    /// - Parameters:
    ///   - private: Private key of wallet.
    ///   - json: Keystore of wallet
    public func importWallet(with private: String?, with json: NSDictionary) {
        //Return value with delegate
        
    }
    
    /**
     Remove wallet.
     
     - parameter private: Private key of wallet.
     - parameter json: Keystore of wallet
     
     - returns: Wallet by NANJWalletManagerDelegate.
     */
    
    
    /// Remove wallet.
    ///
    /// - Parameter wallet: that you want to remove
    /// - Returns: if remove successful return true and opposite
    public func removeWallet(wallet: NANJWallet) -> Bool {
        
        return false
    }
    
    
    /// Enable wallet
    ///
    /// - Parameter wallet: that you want to enable
    /// - Returns: if enable successful return true and opposite
    public func enableWallet(wallet: NANJWallet) -> Bool {
        
        return false
    }
    
    
    /// Return current wallet that is enabled
    ///
    /// - Returns: return current NANJWallet
    public func getCurrentWallet() -> NANJWallet? {
        
        return nil
    }
    
    
    /// After finish get wallets on async function
    /// It return list wallets in callback delegate.
    public func getWalletList() {
        
        
    }
    
    
    /// After finish get a wallet from QR code on async function
    /// It return a NANJWallet in callback delegate.
    public func getWalletFromQRCode() {
        
        
    }
    
    
    /// Return value with delegate
    /// After finish get Rate of NAJI on async function
    /// It return a NANJ Rate in callback delegate.
    public func getNANJRate(){
        

    }

}
