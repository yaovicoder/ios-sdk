//
//  NANJNFCVC.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit
import CoreNFC

@objc protocol NANJNFCDelegate {
    @objc optional func didScanNFC(address: String) -> Void;
    @objc optional func didCloseScan();
}

class NANJNFC: NSObject, NFCNDEFReaderSessionDelegate {
    
    var delegate: NANJNFCDelegate?
    
    @available(iOS 11.0, *)
    fileprivate lazy var session: NFCNDEFReaderSession = {
        return NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
    }()
    
    deinit {
        print("NANJNFC deinit")
    }
    
    func startScan() {
        if #available(iOS 11.0, *) {
            if NFCNDEFReaderSession.readingAvailable {
                self.startNFCSession()
            } else {
                //Device not support
                print("Device not support Scan NFC")
            }
        } else {
            print("Device not support Scan NFC")
        }
    }
    
    func stopScan() {
        if #available(iOS 11.0, *) {
            self.session.invalidate()
        }
    }
    
    //MARK: - Private Function
    @available(iOS 11.0, *)
    fileprivate func startNFCSession() {
        self.session.begin()
    }
    
    
    //MARK: - NFC Delegate
    @available(iOS 11.0, *)
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                print("New Record Found: ")
                let __str: String = String(data: record.payload, encoding: .ascii) ?? "Ko tim thay"
                print(__str)
            }
        }
        self.delegate?.didScanNFC?(address: "address")
    }
    @available(iOS 11.0, *)
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC NDEF Invalidated")
        print("\(error)")
    }
    
}

extension NANJNFC {
    @available(iOS 11.0, *)
    fileprivate func payloadString(payload: NFCNDEFPayload) -> String? {
        let typeStr: String? = String(data: payload.type, encoding: .utf8)
        let length = payload.payload.count
        guard let __type = typeStr else { return nil }
        if length == 0 {
            return nil
        }
        if __type == "T" {
            let payloadBytes: [UInt8] = payload.payload.bytes
            if (length < 1) {
                return nil;
            }
            
            // Parse first byte Text Record Status Byte.
            
//            let isUTF16: Bool = (payloadBytes[0]) && 0x80;
//            let codeLength: UInt8 = payloadBytes[0] && 0x7F
//
//            if (length < 1 + codeLength) {
//                return nil;
//            }
            
            // Get lang code and text.
            //            let langCode: String = [[NSString alloc] initWithBytes:payloadBytes + 1 length:codeLength encoding:NSUTF8StringEncoding];
            //            NSString *text = [[NSString alloc] initWithBytes:payloadBytes + 1 + codeLength
            //                length:length - 1 - codeLength
            //                encoding: (!isUTF16)?NSUTF8StringEncoding:NSUTF16StringEncoding];
            //            if (!langCode || !text) {
            //                return nil;
        }
        return nil
    }
    
}
