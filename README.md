# NANJFrameworks


## Features

- [x] Create NANJ Wallet
- [x] Import NANJ Wallet via Private Key / Key Store
- [x] Export Private Key/ Key Store from NANJ Wallet
- [x] Transfer NANJ Coin
- [x] Transaction History
- [x] Capture Wallet Address via QRCode
- [x] Capture Wallet Address via NFC Tapping

## Requirements
- iOS 10.0+
- Xcode 9.3+
- Swift 3.1+

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
- Trong `AppDelegate.swift` tiên cần import thư viện `NANJFrameworks`
```swift
import NANJFrameworks
```
-  Add following lines to didFinishLaunchingWithOptions method
```swift
NANJWalletManager.shared.startConfig(appId: "AppId", appSecret: "AppSecret", coinName: "CoinName")
```

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


## Author

NANJCOIN, support@nanjcoin.com

## License

NANJFrameworks is available under the MIT license. See the LICENSE file for more info.
