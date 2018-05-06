//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import TrustKeystore

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
    
    /// Callback wallet when export completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet export.
    ///   - privateKey: Private key export from wallet.
    ///   - error: Error during wallet import.
    @objc optional func didExportPrivatekey(wallet: NANJWallet, privateKey: String?, error: Error?)

    /// Callback wallet when export completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet export.
    ///   - keyStore: Private key export from wallet.
    ///   - error: Error during wallet import.
    @objc optional func didExportKeystore(wallet: NANJWallet, keyStore: String?, error: Error?)
    
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
    
    fileprivate lazy var keystore: EtherKeystore = {
        return EtherKeystore.shared
    }()
    
    /**
     Create new wallet.
     
     - returns: Wallet by NANJWalletManagerDelegate.
     */
    public func createWallet(password: String) {
        self.keystore.createAccount(with: password) { result in
            if result.error != nil {
                self.delegate?.didCreateWallet?(wallet: nil, error: nil)
            } else {
                self.delegate?.didCreateWallet?(wallet: result.value?.toNANJWallet(), error: nil)
            }
        }
    }
    
    /// Import a wallet with private key
    ///
    /// - Parameters:
    ///   - privateKey: Private key of wallet.
    public func importWallet(privateKey key: String) {
        //Return value with delegate
        self.keystore.importWallet(type: .privateKey(privateKey: key)) { result in
            if result.error != nil {
                self.delegate?.didImportWallet?(wallet: nil, error: NSError(domain: "com.nanj.error.import", code: 1992, userInfo: ["description":result.error?.errorDescription ?? "com.nanj.error.import"]))
            } else {
                let __wallet: NANJWallet? = result.value?.toNANJWallet()
                self.delegate?.didImportWallet?(wallet: __wallet, error: nil)
            }
        }
    }
    
    /// Import a wallet with json string
    ///
    /// - Parameters:
    ///   - keyStore: Keystore of wallet.
    ///   - password: password of Keystore
    public func importWallet(keyStore key: String, password pass: String) {
        //Return value with delegate
        EtherKeystore.shared.importWallet(type: .keystore(string: key, password: pass)) { result in
            guard let error = result.error else {
                self.delegate?.didImportWallet?(wallet: result.value?.toNANJWallet(), error: nil)
                return
            }
            self.delegate?.didImportWallet?(wallet: nil, error: NSError(domain: "com.nanj.error.import", code: 1992, userInfo: ["description":error.errorDescription ?? "com.nanj.error.import"]))
        }
    }
    
    /// Remove wallet.
    ///
    /// - Parameter wallet: that you want to remove
    /// - Returns: if remove successful return true and opposite
    public func removeWallet(wallet: NANJWallet) -> Bool {
        if let __wallet = wallet.getEtherWallet() {
            return self.keystore.delete(wallet: __wallet).error == nil
        }
        return false
    }
    
    
    public func exportPrivateKey(wallet: NANJWallet) {
        let error = NSError(domain: "com.nanj.error.export", code: 1992, userInfo: ["description": "com.nanj.error.export"])
        guard let address = wallet.getEtherWallet()?.address else {
            self.delegate?.didExportPrivatekey?(wallet: wallet, privateKey: nil, error: error)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if let account = self.keystore.getAccount(for: address) {
                do {
                        let result = try self.keystore.exportPrivateKey(account: account).dematerialize()
                        DispatchQueue.main.async {
                            self.delegate?.didExportPrivatekey?(wallet: wallet, privateKey: result.hexString, error: nil)
                        }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.didExportPrivatekey?(wallet: wallet, privateKey: nil, error: error)
                    }
                }
            }
        }
    }
    
    public func exportKeystore(wallet: NANJWallet, password: String) {
        let error = NSError(domain: "com.nanj.error.export", code: 1992, userInfo: ["description": "com.nanj.error.export"])
        guard let address = wallet.getEtherWallet()?.address else {
            self.delegate?.didExportKeystore?(wallet: wallet, keyStore: nil, error: error)
            return
        }
        if let account = self.keystore.getAccount(for: address) {
            if let currentPassword = self.keystore.getPassword(for: account) {
                self.keystore.export(account: account, password: currentPassword, newPassword: password) { result in
                    if let __keystore = result.value {
                        self.delegate?.didExportKeystore?(wallet: wallet, keyStore: __keystore, error: nil)
                    } else {
                        self.delegate?.didExportKeystore?(wallet: wallet, keyStore: nil, error: error)
                    }                }
            } else {
                self.keystore.export(account: account, password: password, newPassword: password) { result in
                    if let __keystore = result.value {
                        self.delegate?.didExportKeystore?(wallet: wallet, keyStore: __keystore, error: nil)
                    } else {
                        self.delegate?.didExportKeystore?(wallet: wallet, keyStore: nil, error: error)
                    }
                }
            }
        }
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
        if let wallet: Wallet = self.keystore.recentlyUsedWallet {
            return wallet.toNANJWallet()
        }
        return nil
    }
    
    
    /// After finish get wallets on async function
    /// It return list wallets in callback delegate.
    public func getWalletList() {
        let walletList = self.keystore.wallets.map { wallet -> NANJWallet in
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
    
    public func scanAddressFromQRCode() {
        
    }
    
    public func isValidAddress(address: String?) -> Bool {
        return CryptoAddressValidator.isValidAddress(address)
    }
}
