//
//  CategoryAlertView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import Foundation
import UIKit

class CategoryAlertView: UIView {
    @IBOutlet weak var categoryTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> CategoryAlertView {
        return Bundle.main.loadNibNamed("CategoryAlertView", owner: nil, options: nil)!.first as! CategoryAlertView
    }
}

