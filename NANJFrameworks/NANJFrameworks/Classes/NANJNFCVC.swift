//
//  NANJNFCVC.swift
//  NANJFramworks
//
//  Created by Long Lee on 4/15/18.
//

import UIKit

protocol NANJNFCDelegate {
    func didScanNFC(address: String) -> Void;
    func didCloseScan();
}

class NANJNFCVC: UIViewController {
    
    var delegate: NANJNFCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func scanNFC() {
        
    }

}
