//
//  PasswordViewController.swift
//  NANJFrameworks_Example
//
//  Created by Long Lee on 5/6/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class PasswordViewController: BaseViewController {

    @IBOutlet weak var txfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickPassword(_ sender: Any) {
        if (self.txfPassword.text?.length ?? 0) == 0 {
            self.showMessage("Enter password")
            return
        }
        
        //Load local password
        let __password: String? = (UserDefaults.standard.object(forKey: "user_password") as? String) ?? nil

        if (__password != nil) {
            //Check password
            if self.txfPassword.text != __password!  {
                self.showMessage("Password in correct.")
            } else {
                self.gotoMain()
            }
        } else {
            //Save password
            UserDefaults().set(self.txfPassword.text, forKey: "user_password")
            self.gotoMain()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func gotoMain() {
        let navi: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
        UIApplication.shared.delegate?.window??.rootViewController = navi
    }

}
