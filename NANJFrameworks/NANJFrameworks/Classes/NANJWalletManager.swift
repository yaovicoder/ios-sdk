//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

@objc public protocol NANJWalletManagerDelegate {
    
    /// Callback wallet when create completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet has been created.
    ///   - error: Error during wallet creation.
    @objc optional func didCreateWallet(wallet: NANJWallet?, error: Error?)
    
    /// Callback wallet when import completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet has been imported.
    ///   - error: Error during wallet import.
    @objc optional func didImportWallet(wallet: NANJWallet?, error: Error?)
    
    /// Callback wallet list when get completed.
    ///
    /// - Parameters:
    ///   - wallets: list Wallet
    ///   - error: Error during wallet load.
    @objc optional func didGetWalletList(wallets: [NANJWallet]?, error: Error?)
    
    /// Callback wallet list when get from QRCode completed
    ///
    /// - Parameter wallet: Wallet has been read.
    @objc optional func didGetWalletFromQRCode(wallet: NANJWallet?)
    
    /// Callback rate when get completed.
    ///
    /// - Parameter rate: Rate YEN/NANJ
    @objc optional func didGetNANJRate(rate: Double)
}

public class NANJWalletManager: NSObject {

    public static let shared : NANJWalletManager = NANJWalletManager()
    
    public var delegate: NANJWalletManagerDelegate?
    
    /**
     Create new wallet.
     
     - returns: Wallet by NANJWalletManagerDelegate.
     */
    public func createWallet(password: String) {
        EtherKeystore.shared.createAccount(with: password) {[weak self] result in
            guard let `self` = self else {return}
            if result.error != nil {
                self.delegate?.didCreateWallet?(wallet: nil, error: nil)
            } else {
                self.delegate?.didCreateWallet?(wallet: result.value?.toNANJWallet(), error: nil)
            }
        }
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
        wallet.enableWallet()
        return true
    }
    
    
    /// Return current wallet that is enabled
    ///
    /// - Returns: return current NANJWallet
    public func getCurrentWallet() -> NANJWallet? {
        if let wallet: Wallet = EtherKeystore.shared.recentlyUsedWallet {
            return wallet.toNANJWallet()
        }
        return nil
    }
    
    
    /// After finish get wallets on async function
    /// It return list wallets in callback delegate.
    public func getWalletList() {
        let walletList = EtherKeystore.shared.wallets.map { wallet -> NANJWallet in
            let nanjWallet: NANJWallet = NANJWallet()
            nanjWallet.address = wallet.address.eip55String
            nanjWallet.addEtherWallet(wallet: wallet)
            return nanjWallet
        }
        self.delegate?.didGetWalletList?(wallets: walletList, error: nil)
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
