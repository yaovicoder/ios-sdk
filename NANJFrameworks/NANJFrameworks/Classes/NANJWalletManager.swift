//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

public protocol NANJWalletManagerDelegate {
    
    /// Callback wallet when create completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet has been created.
    ///   - error: Error during wallet creation.
    func didCreateWallet(wallet: NANJWallet?, error: Error?)
    
    /// Callback wallet when import completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet has been imported.
    ///   - error: Error during wallet import.
    func didImportWallet(wallet: NANJWallet?, error: Error?)
    
    /// Callback wallet list when get completed.
    ///
    /// - Parameters:
    ///   - wallets: list Wallet
    ///   - error: Error during wallet load.
    func didGetWalletList(wallets: Array<NANJWallet?>, error: Error?)
    
    /// Callback wallet list when get from QRCode completed
    ///
    /// - Parameter wallet: Wallet has been read.
    func didGetWalletFromQRCode(wallet: NANJWallet?)
    
    /// Callback rate when get completed.
    ///
    /// - Parameter rate: Rate YEN/NANJ
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
        let _ss = EtherKeystore.shared.wallets
        print(_ss.count)
    }
    
    /// Import a wallet with private key and json string
    ///
    /// - Parameters:
    ///   - private: Private key of wallet.
    ///   - json: Keystore of wallet
    public func importWallet(with private: String?, with json: NSDictionary) {
        //Return value with delegate
        
    }
    
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
