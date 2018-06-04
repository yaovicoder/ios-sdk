//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import TrustKeystore
import APIKit
import BigInt
import CryptoSwift
import TrustCore
import TrustCore.EthereumCrypto

@objc public protocol NANJWalletManagerDelegate {
    
    /// Callback wallet when create completed.
    ///
    /// - Parameters:
    ///   - wallet: Wallet has been creating.
    @objc optional func didCreatingWallet(wallet: NANJWallet?)
    
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
    
    fileprivate var config: Config = Config()
    var chainState: ChainState!
    
    //ETH adress creating NANJ adress
    fileprivate var followUpAddress: [String] = []
    
    //MARK: - Public function
    
    public func startConfig() {
        //Setup RPC Server
        config.chainID = NANJConfig.rpcServer.chainID
        
        //Start Chain state
        self.chainState = ChainState(config: self.config)
        self.chainState.start()
        
        Timer.scheduledTimer(timeInterval: 15,
                             target: self,
                             selector: #selector(checkNANJWalletCreated),
                             userInfo: nil,
                             repeats: true)
        self.keystore.wallets.forEach { wallet in
            if wallet.toNANJWallet().address.count <= 0 {
                self.followUpAddress.append(wallet.address.eip55String)
            }
        }
    }
    
    /**
     Create new wallet.
     
     - returns: Wallet by NANJWalletManagerDelegate.
     */
    public func createWallet(password: String) {
        self.keystore.createAccount(with: password) {[weak self] result in
            guard let `self` = self else {return}
            if result.error != nil {
                self.delegate?.didCreateWallet?(wallet: nil, error: nil)
            } else {
                //Create NANJ wallet
                let address: Address? = result.value?.address
                self.createNANJWallet(address: address, privateKey: nil)
                //self.delegate?.didCreateWallet?(wallet: result.value?.toNANJWallet(), error: nil)
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
                let address: Address? = result.value?.address
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
            return wallet.toNANJWallet()
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
//        let request: TransactionRequest = TransactionRequest()
//        Session.send(request) {result in
//            switch result {
//            case .success(let transaction):
//                break
//            case .failure(let error):
//
//                print("Get Nonce error")
//                print(error)
//                break
//            }
//        }
    }
    
    public func scanAddressFromQRCode() {
        
    }
    
    public func isValidAddress(address: String?) -> Bool {
        return CryptoAddressValidator.isValidAddress(address)
    }
    
    public func createNANJWallet(address: Address?, privateKey: String?) {
        guard let currentAddress = address else {
            print("No account")
            return
        }
        
        var _privateKey: String = privateKey ?? ""
        
        if _privateKey.count == 0 {
            //Get Private key
            if let account = self.keystore.getAccount(for: currentAddress) {
                do {
                    let result = try self.keystore.exportPrivateKey(account: account).dematerialize()
                    _privateKey = result.hexString
                } catch {
                    //Error
                }
            }
        }
        
        //STEP1: FUNCTION ENCODE
        print("* * * * * * * * * * * * STEP 1 * * * * * * * * * * * *")
        let function = Function(name: "createWallet", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [currentAddress])
        //print(encoder.data.hexEncoded)
        let functionEndcodeData = encoder.data
        print(functionEndcodeData.hexEncoded)
        print("\n\n")
        
        //STEP2: SIGN FUNCTION ENCODE
        print("* * * * * * * * * * * * STEP 2 * * * * * * * * * * * *")
        let signature = EthereumCrypto.sign(hash: functionEndcodeData, privateKey: _privateKey.data(using: .utf8)!)
        
        let dataR = signature[..<32]
        let signR = dataR.hexEncoded
        print("R: ", signR)
        
        let dataS = signature[32..<64]
        let signS = dataS.hexEncoded
        print("S: ", signS)
        
        let signV = signature[64] + 27
        print("V: ", signV)
    
        print("\n")
        
        //STEP3: CREATE TX_HASH INPUT WITH TX_RELAY, WALLET OWNER,
        //              PAD, NANJCOIN ADDRESS
        print("* * * * * * * * * * * * STEP 3 * * * * * * * * * * * *")
        let txHashInput = String(format: "0x1900%@%@%@%@%@",
                                 NANJConfig.TX_RELAY_ADDRESS.drop0x,
                                 NANJConfig.WALLET_OWNER.drop0x,
                                 NANJConfig.PAD,
                                 NANJConfig.NANJCOIN_ADDRESS.drop0x,
                                 functionEndcodeData.hexEncoded.drop0x
                      )
        print("Hash Input: ", txHashInput)
        print("\n")
        
        //STEP4: SHA3 TX_HASH
        print("* * * * * * * * * * * * STEP 4 * * * * * * * * * * * *")
        let txHashData = txHashInput.data(using: .utf8)?.sha3(.keccak256)
        let txHash: String = txHashData?.hexEncoded  ?? "TX HASH ERROR"
        print("txHash: ", txHash)
        print("\n")
        
        //STEP5: CREATE JSON DATA
        print("* * * * * * * * * * * * STEP 5 * * * * * * * * * * * *")
        let para:NSMutableDictionary = NSMutableDictionary()
        para.setValue(functionEndcodeData.hexEncoded, forKey: "data")
        para.setValue(NANJConfig.NANJCOIN_ADDRESS, forKey: "dest")
        para.setValue(txHash, forKey: "hash")
        para.setValue(NANJConfig.PAD, forKey: "nonce")
        para.setValue(signR, forKey: "r")
        para.setValue(signS, forKey: "s")
        para.setValue(signV, forKey: "v")
        let jsonData = try! JSONSerialization.data(withJSONObject: para, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        print(jsonString)
        print("\n")
        
        //STEP6: PUSH TO API CREATE https://nanj-demo.herokuapp.com/api/relayTx
        print("* * * * * * * * * * * * STEP 6 * * * * * * * * * * * *")
        NANJApiManager.shared.createNANJWallet(params: para) {[weak self] txHash in
            guard let `self` = self else {return}
            print(txHash ?? "Completion create wallet")
            //Add to check NANJ create success
            self.followUpAddress.append(currentAddress.eip55String)
            
            self.delegate?.didCreatingWallet?(wallet: Wallet(type: .address(currentAddress)).toNANJWallet())
            //self.delegate?.didCreateWallet?(wallet: Wallet(type: .address(currentAddress)).toNANJWallet(), error: nil)
        }
        print("\n")
    }
    
    //MARK: - Private function
    
    @objc private func checkNANJWalletCreated() {
        print("checkNANJWalletCreated")
        self.followUpAddress.forEach { address in
            print("NANJ Adress  - - - - - - - ")
            NANJApiManager.shared.getNANJAdress(ethAdress: address, completion: {[weak self] nanjAddress in
                guard let `self` = self else {return}
                print(nanjAddress ?? "NANJ Adress error")
                let addressNANJ = nanjAddress?.replacingOccurrences(of: "000000000000000000000000", with: "")
                if self.isValidAddress(address: addressNANJ) {
                    guard let __adress = Address(eip55: address) else {return}
                    UserDefaults.standard.set(addressNANJ, forKey: address)
                    UserDefaults.standard.synchronize()
                    print(addressNANJ ?? "NANJ Adress error")
                    
                    self.delegate?.didCreateWallet?(wallet: Wallet(type: .address(__adress)).toNANJWallet(), error: nil)
                    
                    //Remove follow up
                    if let index = self.followUpAddress.index(of: address) {
                        self.followUpAddress.remove(at: index)
                    }
                }
            })
        }
    }
}
