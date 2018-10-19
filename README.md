<p align="center" >
<img src="https://camo.githubusercontent.com/c3b1bd7b3ebd22b22dd5e59e7f927f27bbef6216/68747470733a2f2f6e616e6a636f696e2e636f6d2f6e616e6a732e706e67" width=100px alt="SwiftDate" title="SwiftDate">
<h1 align="center">NANJ SDK PROJECT</h1>
<h4 align="center">CODE NAME: FIERCE TIGER</h4>
</p>
<p align="center">
<a href="https://discordapp.com/channels/403479501625098241">
<img alt="Discord" src="https://img.shields.io/discord/403479501625098241.svg" />
</a>
</p>
## Features

- [x] Create NANJ Wallet
- [x] Import NANJ Wallet via Private Key / Key Store
- [x] Export Private Key/ Key Store from NANJ Wallet
- [x] Transfer NANJ Coin
- [x] Transaction History
- [x] Get NANJCOIN Rate in JPY
- [x] Capture Wallet Address via QRCode
- [x] Capture Wallet Address via NFC Tapping
- [x] Get minimum allowed amount on transfer for specific ERC20 Token
- [x] Get maximum transaction fee on transfer for specific ERC20 Token
- [x] Get NANJCOIN rate in USD

## Requirements
- iOS 10.0+
- Xcode 9.3+
- Swift 3.1+

## Communication
- If you **need help** or **ask a general question**, use 
[![Discord Chat](https://img.shields.io/discord/403479501625098241.svg)](https://discord.gg/xa94m8F)  
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `NANJFrameworks` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
pod 'NANJFrameworks'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage
### Initialization
- In `AppDelegate.swift` ,  import  `NANJFrameworks`
```swift
import NANJFrameworks
```
-  Add following lines to didFinishLaunchingWithOptions method

```swift
//Set Development Mode
NANJWalletManager.shared.setDevelopmentMode(isDevelopment: true)
NANJWalletManager.shared.startConfig(appId: "AppId", appSecret: "AppSecret", coinName: "CoinName")
```

### Environment Setup

Development mode with staging server
```swift
NANJWalletManager.shared.setDevelopmentMode(isDevelopment: true)
```

Production mode with production server
```swift
NANJWalletManager.shared.setDevelopmentMode(isDevelopment: false)
```

**Notes**: Please call the method before `startConfig`
### Create new Wallet
To create new wallet, use CreateWallet method via shared instance of NANJWalletManager
```swift
NANJWalletManager.shared.createWallet(password:"Password")
```

To receive event of successful wallet creation, assign `delegate` in `NANJWalletManager`
```swift
NANJWalletManager.shared.delegate = self
```
Once wallet creating, the delegate will call via method: 
```swift
func didCreatingWallet(wallet: NANJWallet?)
```
Once wallet created, the delegate will call via method
```swift
func didCreateWallet(wallet: NANJWallet?, error: Error?) {
```

### Import wallet
- With Private key
```swift
NANJWalletManager.shared.importWallet(privateKey: "Private Key")
```
- With Key store (Bear in mind that we will need password to unlock keystore)
```swift
NANJWalletManager.shared.importWallet(keyStore "Key Store", password "Password")
```

If wallet is imported successfully, the delegate will be invoked via method
```swift
func didImportWallet(wallet: NANJWallet?, error: Error?)
```
Return `wallet` if successful import,
`error` if there is an error.


### Export Wallet
- Export private key

```swift
NANJWalletManager.shared.exportPrivateKey(wallet: "NANJWallet")
```
`Private key` will be received via a method of delegate
```swift
func didExportPrivatekey(wallet: NANJWallet, privateKey: String?, error: Error?, error: nil)
```
return `String` `privateKey` if successful export.

And `Error` if there is a error.
- Export keystore
```swift
NANJWalletManager.shared.exportKeystore(wallet: "NANJWallet", password: "Password")
```
Similar to export private key, export keystore will return over `delegate` with method
```swift
func didExportKeystore(wallet: NANJWallet, keyStore: String?, error: Error?)
```

### Transfer NANJCOIN
In order to send NANJ Coin to a specific address, Use `NANJWallet` instance to send like lines of code below
```swift
self.currentWallet = NANJWalletManager.shared.getCurrentWallet()
self.currentWallet?.delegate = self
self.currentWallet?.sendNANJ(toAddress: "NANJ Address", amount: "Amount send")
```
Outcome of sending NANJCoin will be confirmed over `delegate` with method
```swift
func didSendNANJCompleted(transaction: NANJTransaction?)
```

Or error persist via
```swift
func didSendNANJError(error: String?)
```
### Get NANJCOIN Rate in JPY

```swift
self.currentWallet?.delegate = self
self.currentWallet?.getNANJRate()
```

NANJ rate will be returned over delegate method

```swift
@objc optional func didGetNANJRate(rate: Double)
```

### Get NANJCOIN Rate in JPY or USD

```swift
self.walletManager.delegate = self
self.walletManager.getNANJRateWith(currency: string)
```
Currency symbol for input the method `getNANJRateWith`

**US Dollar** : `'usd'` and **JPY** : `'jpy'`

NANJ rate will be returned over delegate method

```swift
@objc optional func didGetNANJCurrencyRate(rate: Double, currency: String)
```

### Get transaction list
```swift
self.currentWallet?.delegate = self
self.currentWallet?.getTransactionList(page: 1, offset: 20)
```

Receive via delegate call

```swift
func didGetTransactionList(transactions: Array<NANJTransaction>?)
```

NANJTransaction Class
```swift
public class NANJTransaction: NSObject {
public let id: UInt?
public let txHash: String?
public let status: Int?
public let from: String?
public let to: String?
public let value: String?
public let message: String?
public let txFee: String?
public let timestamp: UInt?
public let tokenSymbol: String?
...
}
```

### Get minimum amount, max transaction fee per transfer
After set current ERC20 token. SDK can get minimum amount and maximum transaction fee. This minimum amount and maximum fee will be for chosen ERC20 token. 

Get minimum amount per transfer

`NANJWalletManager.shared.getMinimumAmount()`

Get maximum fee per transfer

`NANJWalletManager.shared.getMaxFee()`

### NANJ SDK Support mutiple ERC20/ERC223
To retreive supported ERC20/ERC223
```swift 
let arrayOfERC20 = NANJWalletManager.shared.getListERC20Support()
```

To retreive supported ERC20/ERC223 by Identifier of ERC20

```swift 
let idERC20 = 1
let arrayOfERC20 = NANJWalletManager.shared.getERC20Support(idERC20)
```

To use ERC20/ERC223

```swift
let idERC20 = 1
NANJWalletManager.shared.setCurrentERC20Support(idERC20)

```

To retrieve current ERC20/ERC223

```swift
NANJWalletManager.shared.getCurrentERC20Support(idERC20)
```

This feature allows the SDK can switch among multiple ERC20/ERC223 coins

## Author

NANJCOIN, support@nanjcoin.com

## License
please read our license at this link. [LICENSE](https://nanjcoin.com/sdk)
you can change Language JP/EN
