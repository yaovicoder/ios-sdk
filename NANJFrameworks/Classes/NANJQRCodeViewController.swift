//
//  NANJQRCodeVC.swift
//  NANJFramworks
//
//  Created by MinaWorks on 4/15/18.
//

import UIKit
import AVFoundation

@objc public protocol NANJQRCodeDelegate {
    @objc optional func didScanQRCode(address: String) -> Void;
    @objc optional func didCloseScan();
}

public class NANJQRCodeViewController: UIViewController {
    
    public var delegate: NANJQRCodeDelegate?
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    lazy var btnClose: UIButton = {
        let btnClose: UIButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44))
        btnClose.backgroundColor = UIColor.lightGray
        btnClose.setTitleColor(UIColor.black, for: .normal)
        btnClose.setTitle("CLOSE", for: .normal)
        return btnClose
    }()

    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]


    override public func viewDidLoad() {
        super.viewDidLoad()
        self.initLayout()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Deinit QRCode")
    }
    
    func initLayout() {
        guard let captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            print(error)
            return
        }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }

        self.view.addSubview(self.btnClose)
        self.btnClose.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        view.bringSubview(toFront: self.btnClose)
    }
    
    @objc func closeVC() -> Void {
        self.delegate?.didCloseScan?()
        self.dismiss(animated: true, completion: nil)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.btnClose.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44)
    }
}

extension NANJQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No QR code is detected")
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let __object: String = metadataObj.stringValue {
                if __object.contains(Character.init(":")) {
                    let ether: [String] = __object.split(separator: Character.init(":")).map(String.init)
                    ether.forEach { address in
                        if NANJWalletManager.shared.isValidAddress(address: address) {
                            //Close scan
                            self.delegate?.didScanQRCode?(address: address)
                            self.closeVC()
                        } else {
                            print("Invalid Address")
                        }
                    }
                } else {
                    if NANJWalletManager.shared.isValidAddress(address: metadataObj.stringValue) {
                        //Close scan
                        self.delegate?.didScanQRCode?(address: metadataObj.stringValue!)
                        self.closeVC()
                    } else {
                        print("Invalid Address")
                    }
                }
            }
        }
    }
    
}


