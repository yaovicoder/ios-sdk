//
//  NDETextField.swift
//  NDE
//
//  Created by Long Lee on 1/19/18.
//  Copyright © 2018 iKite Labs. All rights reserved.
//

import UIKit

class NDETextField: UITextField {
    
    @IBInspectable
    public var paddingLeft: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        if paddingLeft > 0 {
            return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, paddingLeft, 0, 0))
        }
        return super.textRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if paddingLeft > 0 {
            return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, paddingLeft, 0, 0))
        }
        return super.textRect(forBounds: bounds)
    }
    
}
