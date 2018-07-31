//
//  NANJConfig.swift
//  NANJFrameworks
//
//  Created by MinaWorks on 5/6/18.

import Foundation

public struct NANJConfig {
    static var rpcServer: RPCServer = RPCServer.main
    static var nanjServer: String = "https://api.nanjcoin.com/api"

    static var txRelayAddress: String = "0x7e861e36332693f271c66bdab40cda255a50d005"
    static var metaNanjCoinManager: String = "0x8801307aec8ed852ea23d3d4e69f475f4f2dcb6e"
    static var smartContractAddress: String = "0xf7afb89bef39905ba47f3877e588815004f7c861"
    
    static var appHash: String = ""
    static var nanjWalletAppId: String = ""
    static var nanjWalletSecretKey: String = ""
    
    static var nanjCoinName: String = ""
    static var symbol: String = "ESNJ"
    static var decimals: Int = 8
    static var isDevelopment: Bool = false
    
    static let NANJ_SERVER_STAGING: String = "https://api.nanjcoin.com/api" //"https://staging.nanjcoin.com/api"
    static let WALLET_OWNER: String = "0x0000000000000000000000000000000000000000"
    static let PAD: String = "0000000000000000000000000000000000000000000000000000000000000000"
}

public class NANJDataConfig: NSObject {
    var client_id: String = ""
    var name: String = ""
    var eth_address: String = ""
    var status: Int = 0
    var version: String = ""
    var metaNanjManager: String = "" //smartContracts{ metaNanjManager }
    var txRelay: String = ""
    var supportedERC20: [ERC20] = []
    var appHash: String = ""
    var env: String = ""
    var chainId: String = ""
    
    init(val: NSDictionary) {
        super.init()
        if let __client_id = val["client_id"] as? String {
            self.client_id = __client_id
        }
        if let __name = val["name"] as? String {
            self.name = __name
        }
        if let __eth_address = val["eth_address"] as? String {
            self.eth_address = __eth_address
        }
        if let __status = val["status"] as? Int {
            self.status = __status
        }
        if let __version = val["version"] as? String {
            self.version = __version
        }
        if let smartContracts = val["smartContracts"] as? NSDictionary {
            if let __metaNanjManager  = smartContracts["metaNanjManager"] as? String {
                self.metaNanjManager = __metaNanjManager
            }
            
            if let __txRelay  = smartContracts["txRelay"] as? String {
                self.txRelay = __txRelay
            }
        }
        if let supportedERC20  = val["supportedERC20"] as? [NSDictionary] {
            //List ERC20
            var __ERC20: [ERC20] = []
            supportedERC20.forEach { dict in
                __ERC20.append(ERC20(val: dict))
            }
            self.supportedERC20 = __ERC20
        }
        if let __appHash = val["appHash"] as? String {
            self.appHash = __appHash
        }
        if let __env = val["env"] as? String {
            self.env = __env
        }
        if let __chainId = val["chainId"] as? String {
            self.chainId = __chainId
        }
    }
}

public class ERC20: NSObject {
    var ercId: Int = 0
    var name: String = ""
    var address: String = ""
    
    init(val: NSDictionary) {
        if let __id = val["id"] as? Int {
            self.ercId = __id
        }
        if let __name = val["name"] as? String {
            self.name = __name
        }
        if let __address = val["address"] as? String {
            self.address = __address
        }
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getERC20Id() -> Int {
        return self.ercId
    }
    
    public func getERC20Address() -> String {
        return self.address
    }
}
