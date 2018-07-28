//
//  NANJWalletManager.swift
//  NANJFramworks
//
//  Created by MinaWorks on 4/15/18.
//

import UIKit
import TrustKeystore
import APIKit
import BigInt
import CryptoSwift
import TrustCore
import TrustCore.EthereumCrypto

@objc public protocol NANJWalletManagerDelegate {
    
    /// Callback when authorise completed.
    ///
    /// - Parameters:
    @objc optional func didAuthoriseSuccess()
    
    /// Callback when authorise completed.
    ///
    /// - Parameters:
    @objc optional func didAuthoriseFail(error: String)
    
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
    /// - Parametvar:
    ///   - wallet: Wallet expvar.
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
    
    public weak var delegate: NANJWalletManagerDelegate?
    
    fileprivate lazy var keystore: EtherKeystore = {
        return EtherKeystore.shared
    }()
    
    fileprivate var config: Config = Config()
    fileprivate var nanjRate: Double?
    fileprivate var remoteConfig: NANJDataConfig?
    fileprivate var supportERC20Id: Int = 1 //Start with NANJ Coin id = 1
    
    //ETH adress creating NANJ adress
    fileprivate var followUpAddress: [String] = []
    
    //MARK: - Public function
    
    /**
     Start config developer, coin info.
     */
    public func startConfig(appId: String, appSecret: String) {
        //Setup developer info
        NANJConfig.NANJWALLET_APP_ID = appId
        NANJConfig.NANJWALLET_SECRET_KEY = appSecret
        
        //Load cache config
        if let data: NSDictionary = UserDefaults.standard.value(forKey: "NANJDataConfig") as? NSDictionary {
            self.remoteConfig = NANJDataConfig(val: data)
            self.updateNANJConfigRemote()
        }
        //Cache ERC20 Support
        if let __supportERC20Id = UserDefaults.standard.value(forKey: "NANJConfigERC20ID") as? Int {
            if let __erc20 = self.getERC20Support(__supportERC20Id) {
                self.updateNANJConfigERC20(__erc20)
            }
        }
        
        //Load new remote config
        self.startAuthorise()
        
        //Setup RPC Server
        config.chainID = NANJConfig.rpcServer.chainID
        
        //Get NANJ Rate
        self.getNANJRate()
        
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
     Set Development Mode.
     */
    public func setDevelopmentMode(isDevelopment: Bool) {
        //Default is Main Net
        if isDevelopment {
            NANJConfig.rpcServer = RPCServer.ropsten
            NANJConfig.NANJ_SERVER = NANJConfig.NANJ_SERVER_STAGING
            NANJConfig.IS_DEVELOPMENT = true
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
                self.delegate?.didCreateWallet?(wallet: nil, error: NSError(domain: "com.nanj.error.create", code: 1992, userInfo: ["description":result.error?.errorDescription ?? "com.nanj.error.create"]))

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
        self.keystore.importWallet(type: .privateKey(privateKey: key)) {[weak self] result in
            guard let `self` = self else {return}
            if result.error != nil {
                self.delegate?.didImportWallet?(wallet: nil, error: NSError(domain: "com.nanj.error.import", code: 1992, userInfo: ["description":result.error?.errorDescription ?? "com.nanj.error.import"]))
            } else {
                let address: Address? = result.value?.address
                //let __wallet: NANJWallet? = result.value?.toNANJWallet()
                //self.delegate?.didImportWallet?(wallet: __wallet, error: nil)
                self.importedGetOrCreateNANJWallet(address: address, privateKey: key)
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
            guard let wallet = result.value else {
                self.delegate?.didImportWallet?(wallet: nil, error: NSError(domain: "com.nanj.error.import", code: 1992, userInfo: ["description": "com.nanj.error.import"]))
                return
            }
            let address: Address? = wallet.address
            //self.delegate?.didImportWallet?(wallet: wallet.toNANJWallet(), error: nil)
            self.importedGetOrCreateNANJWallet(address: address, privateKey: key)
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
        return true
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
            if wallet.toNANJWallet().address.count > 0 {
                return wallet.toNANJWallet()
            }
        }
        return nil
    }
    
    
    /// After finish get wallets on async function
    /// It return list wallets in callback delegate.
    public func getWalletList() {
        var walletList = self.keystore.wallets.map { wallet -> NANJWallet in
            return wallet.toNANJWallet()
        }
        walletList = walletList.filter({ currentWallet -> Bool in
            return currentWallet.address.count > 0
        })
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
        if let rate = self.nanjRate {
            self.delegate?.didGetNANJRate?(rate: rate)
            return
        }
        NANJApiManager.shared.getNANJRate{[weak self] rate in
            guard let `self` = self else {return}
            self.nanjRate = rate;
            self.delegate?.didGetNANJRate?(rate: rate ?? 0.0)
        }
    }
    
    public func scanAddressFromQRCode() {
        
    }
    
    public func isValidAddress(address: String?) -> Bool {
        return CryptoAddressValidator.isValidAddress(address)
    }
    
    public func getListERC20Support() -> [ERC20]? {
        if let __erc20 = self.remoteConfig?.supportedERC20 {
            return __erc20
        }
        return nil
    }
    
    public func getERC20Support(_ ERC20Id: Int) -> ERC20? {
        let erc20 = self.remoteConfig?.supportedERC20.filter({ obj -> Bool in
            return obj.ercId == ERC20Id
        })
        return erc20?.first
    }
    
    public func setCurrentERC20Support(_ ERC20Id: Int) -> Bool {
        let erc20 = self.remoteConfig?.supportedERC20.filter({ obj -> Bool in
            return obj.ercId == ERC20Id
        })
        guard let __erc20: [ERC20] = erc20, let __obj: ERC20 = __erc20.first else { return false }
        self.updateNANJConfigERC20(__obj)
        return true
    }
    
    public func getCurrentERC20Support() -> ERC20? {
        let erc20 = self.remoteConfig?.supportedERC20.filter({ obj -> Bool in
            return obj.ercId == self.supportERC20Id
        })
        return erc20?.first
    }
    
    //MARK: - Private function
    private func importedGetOrCreateNANJWallet(address: Address?, privateKey: String?) {
        guard let addressETH = address?.eip55String, let __address = address else {return}
        NANJApiManager.shared.getNANJAdress(ethAdress: addressETH) {[weak self] nanjAddress in
            guard let `self` = self else {return}
            if nanjAddress == nil || (nanjAddress?.drop0x ?? "") == NANJConfig.PAD {
                //self.delegate?.didCreatingWallet?(wallet: Wallet(type: .address(__address)).toNANJWallet())
                self.createNANJWallet(address: address, privateKey: privateKey)
            } else {
                let addressNANJ = nanjAddress?.replacingOccurrences(of: "000000000000000000000000", with: "")
                if self.isValidAddress(address: addressNANJ) {
                    UserDefaults.standard.set(addressNANJ, forKey: addressETH)
                    UserDefaults.standard.synchronize()
                    
                    self.delegate?.didImportWallet?(wallet: Wallet(type: .address(__address)).toNANJWallet(), error: nil)
                }
            }
        }
    }
    
    private func createNANJWallet(address: Address?, privateKey: String?) {
        guard let currentAddress = address, let currentAccount = self.keystore.getAccount(for: currentAddress) else {
            return
        }
        
        var _privateKey: String = privateKey ?? ""
        
        if _privateKey.count == 0 {
            do {
                let result = try self.keystore.exportPrivateKey(account: currentAccount).dematerialize()
                _privateKey = result.hexString
            } catch {
                //Error
            }
        }
        
        //STEP1: FUNCTION ENCODE
        print("* * * * * * * * * * * * STEP 1 * * * * * * * * * * * *")
        let function = Function(name: "createWallet", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [currentAddress])
        let functionEndcodeData = encoder.data
        
        //STEP2: CREATE TX_HASH INPUT WITH TX_RELAY, WALLET OWNER,
        //              PAD, NANJCOIN ADDRESS
        let txHashInput = String(format: "0x1900%@%@%@%@%@",
                                 NANJConfig.TX_RELAY_ADDRESS.drop0x,
                                 NANJConfig.WALLET_OWNER.drop0x,
                                 NANJConfig.PAD,
                                 NANJConfig.META_NANJCOIN_MANAGER.drop0x,
                                 functionEndcodeData.hexEncoded.drop0x
                      )
        
        //STEP3: CREATE TX_HASH INPUT WITH TX_RELAY
        let __bytes = Array<UInt8>(hex: txHashInput)
        let __hash = Digest.sha3(__bytes, variant: .keccak256)
        let txHash = __hash.toHexString().add0x
        
        //STEP4: SHA3 TX_HASH
        let __bytesSign = Array<UInt8>(hex: txHashInput)
        let __hashSign = Digest.sha3(__bytesSign, variant: .keccak256)
        let __txHashSignData = self.keystore.signHash(Data(bytes: __hashSign), for: currentAccount)
        guard let __txHashSign = __txHashSignData.value  else {
            return
        }
        
        let dataR = __txHashSign[..<32]
        let signR = dataR.hexEncoded
        
        let dataS = __txHashSign[32..<64]
        let signS = dataS.hexEncoded
        
        let signV = __txHashSign[64]// + 27
        
        //STEP5: CREATE JSON DATA
        let para:NSMutableDictionary = NSMutableDictionary()
        para.setValue(functionEndcodeData.hexEncoded, forKey: "data")
        para.setValue(NANJConfig.META_NANJCOIN_MANAGER, forKey: "dest")
        para.setValue(txHash, forKey: "hash")
        para.setValue(NANJConfig.PAD, forKey: "nonce")
        para.setValue(signR, forKey: "r")
        para.setValue(signS, forKey: "s")
        para.setValue(signV, forKey: "v")
        
        //STEP6: PUSH TO API CREATE /api/relayTx
        NANJApiManager.shared.createNANJWallet(params: para) {[weak self] txHash in
            guard let `self` = self else {return}
            //Add to check NANJ create success
            if txHash == nil {
                _ = self.removeWallet(wallet: Wallet(type: .address(currentAddress)).toNANJWallet())
                let error = NSError(domain: "com.nanj.error.create.server", code: 1992, userInfo: ["description": "Server create NANJ Wallet failed."])
                self.delegate?.didCreateWallet?(wallet: nil, error: error)
                return
            }
            
            self.followUpAddress.append(currentAddress.eip55String)
            
            self.delegate?.didCreatingWallet?(wallet: Wallet(type: .address(currentAddress)).toNANJWallet())
        }
    }
    
    @objc private func checkNANJWalletCreated() {
        self.followUpAddress.forEach { address in
            NANJApiManager.shared.getNANJAdress(ethAdress: address, completion: {[weak self] nanjAddress in
                guard let `self` = self else {return}
                let addressNANJ = nanjAddress?.replacingOccurrences(of: "000000000000000000000000", with: "")
                if self.isValidAddress(address: addressNANJ) {
                    UserDefaults.standard.set(addressNANJ, forKey: address)
                    UserDefaults.standard.synchronize()
                    
                    //Return wallet in local
                    let walletList = self.keystore.wallets.filter({ wallet -> Bool in
                        return wallet.address.eip55String == address
                    })
                    if let walletObj = walletList.first {
                        self.delegate?.didCreateWallet?(wallet: walletObj.toNANJWallet(), error: nil)
            
                        //Remove follow up
                        if let index = self.followUpAddress.index(of: address) {
                            self.followUpAddress.remove(at: index)
                        }
                    }
                }
            })
        }
    }
    
    private func startAuthorise() {
        let request: GetAuthoriseRequest = GetAuthoriseRequest()
        Session.send(request) {[weak self] result in
            guard let `self` = self else {return}
            switch result {
            case .success(let dict):
                guard let data: NSDictionary = dict?["data"] as? NSDictionary, let _ = data["appHash"] as? String,
                    let smartContracts = data["smartContracts"] as? NSDictionary,
                    let _ = smartContracts["metaNanjManager"] as? String,
                    let _ = data["supportedERC20"] as? [NSDictionary]
                else {
                    self.delegate?.didAuthoriseFail?(error: "Can not get data from NANJ server.")
                    return
                }
                //Save cache data
                UserDefaults.standard.set(data, forKey: "NANJDataConfig")
                
                //Update Data
                self.remoteConfig = NANJDataConfig(val: data)
                self.updateNANJConfigRemote()
                break
            case .failure(let error):
                self.delegate?.didAuthoriseFail?(error: error.localizedDescription)
                break
            }
        }
    }
    
    //Update for support switch coins
    private func updateNANJConfigERC20(_ erc20: ERC20) {
        NANJConfig.SMART_CONTRACT_ADDRESS = erc20.address
        NANJConfig.NANJ_COIN_NAME = erc20.name
        UserDefaults.standard.set(erc20.ercId, forKey: "NANJConfigERC20ID")
        self.supportERC20Id = erc20.ercId
    }
    
    //Call update when get data from server successfully
    private func updateNANJConfigRemote() {
        if let __remote = self.remoteConfig {
            NANJConfig.APP_HASH = __remote.appHash
            NANJConfig.META_NANJCOIN_MANAGER = __remote.metaNanjManager
            NANJConfig.TX_RELAY_ADDRESS = __remote.txRelay
            
            //Need set default ERC20 support
            // 1. Check not NANJConfigERC20 key
            // 2. Update first object ERC20
            if let _ = UserDefaults.standard.value(forKey: "NANJConfigERC20ID") as? Int {
            } else {
                if let __erc20 = self.remoteConfig?.supportedERC20.first {
                    self.updateNANJConfigERC20(__erc20)
                }
            }
        }
    }
}
