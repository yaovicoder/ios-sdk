// Copyright SIX DAY LLC. All rights reserved.

import Foundation

public struct Constants {
    //
    public static let keychainKeyPrefix = "nanjwallet"

}

public struct UnitConfiguration {
    public static let gasPriceUnit: EthereumUnit = .gwei
    public static let gasFeeUnit: EthereumUnit = .ether
}

public struct URLSchemes {
    public static let nanj = "nanj://"
    public static let browser = nanj + "browser"
}
