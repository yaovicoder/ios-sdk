//
//  BaseViewController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 4/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseViewController: UIViewController {

    lazy fileprivate var progressHUD: MBProgressHUD = {
        var progressHUD: MBProgressHUD = MBProgressHUD(view: self.view)
        return progressHUD
    }()
    
    func showLoading() {
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func showMessage(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideLoading() {
        self.progressHUD.hide(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
