// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum NetworkType {
    case main
    case test
    case custom
}

enum RPCServer {
    case main
    case kovan
    case ropsten
    case rinkeby
    case poa
    case sokol
    case classic
    case callisto

    var chainID: Int {
        switch self {
        case .main: return 1
        case .kovan: return 42
        case .ropsten: return 3
        case .rinkeby: return 4
        case .poa: return 99
        case .sokol: return 77
        case .classic: return 61
        case .callisto: return 104729
        }
    }

    var name: String {
        switch self {
        case .main: return "Ethereum"
        case .kovan: return "Kovan"
        case .ropsten: return "Ropsten"
        case .rinkeby: return "Rinkeby"
        case .poa: return "POA Network"
        case .sokol: return "Sokol"
        case .classic: return "Ethereum Classic"
        case .callisto: return "Callisto"
        }
    }

    var displayName: String {
        return "\(self.name) (\(self.symbol))"
    }

    var networkType: NetworkType {
        switch self {
        case .main, .poa, .classic, .callisto: return .main
        case .kovan, .ropsten, .rinkeby, .sokol: return .test
        }
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .classic: return "ETC"
        case .callisto: return "CLO"
        case .ropsten, .rinkeby: return "ETH"
        case .kovan: return "KETH"
        case .poa: return "POA"
        case .sokol: return "SPOA"
        }
    }

    var decimals: Int {
        return 18
    }

    var rpcURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://mainnet.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .classic: return "https://web3.gastracker.io"
            case .callisto: return "https://rpc.callisto.network"
            case .kovan: return "https://kovan.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .ropsten: return "https://ropsten.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .rinkeby: return "https://rinkeby.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .poa: return "https://core.poa.network"
            case .sokol: return "https://sokol.poa.network"
            }
        }()
        return URL(string: urlString)!
    }
    
    var rpcEtherScanURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://etherscan.io"
            case .classic: return "https://web3.gastracker.io"
            case .callisto: return "https://rpc.callisto.network"
            case .kovan: return "https://kovan.etherscan.io"
            case .ropsten: return "https://ropsten.etherscan.io"
            case .rinkeby: return "https://rinkeby.etherscan.io"
            case .poa: return "https://core.poa.network"
            case .sokol: return "https://sokol.poa.network"
            }
        }()
        return URL(string: urlString)!
    }
    
    var remoteURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://api.trustwalletapp.com"
            case .classic: return "https://classic.trustwalletapp.com"
            case .callisto: return "https://callisto.trustwalletapp.com"
            case .kovan: return "https://kovan.trustwalletapp.com"
            case .ropsten: return "https://ropsten.trustwalletapp.com"
            case .rinkeby: return "https://rinkeby.trustwalletapp.com"
            case .poa: return "https://poa.trustwalletapp.com"
            case .sokol: return "https://trust-sokol.herokuapp.com"
            }
        }()
        return URL(string: urlString)!
    }

    init(name: String) {
        self = {
            switch name {
            case RPCServer.main.name: return .main
            case RPCServer.classic.name: return .classic
            case RPCServer.callisto.name: return .callisto
            case RPCServer.kovan.name: return .kovan
            case RPCServer.ropsten.name: return .ropsten
            case RPCServer.rinkeby.name: return .rinkeby
            case RPCServer.poa.name: return .poa
            case RPCServer.sokol.name: return .sokol
            default: return .main
            }
        }()
    }

    init(chainID: Int) {
        self = {
            switch chainID {
            case RPCServer.main.chainID: return .main
            case RPCServer.classic.chainID: return .classic
            case RPCServer.callisto.chainID: return .callisto
            case RPCServer.kovan.chainID: return .kovan
            case RPCServer.ropsten.chainID: return .ropsten
            case RPCServer.rinkeby.chainID: return .rinkeby
            case RPCServer.poa.chainID: return .poa
            case RPCServer.sokol.chainID: return .sokol
            default: return .main
            }
        }()
    }
}

extension RPCServer: Equatable {
    static func == (lhs: RPCServer, rhs: RPCServer) -> Bool {
        switch (lhs, rhs) {
        case (let lhs, let rhs):
            return lhs.chainID == rhs.chainID
        }
    }
}
