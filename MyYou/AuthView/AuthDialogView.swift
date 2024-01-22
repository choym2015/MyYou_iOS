//
//  AuthDialogView.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 1/18/24.
//

import UIKit
import Foundation

class AuthDialogView: UIView {
    
    @IBOutlet weak var titleText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> AuthDialogView {
        return Bundle.main.loadNibNamed("AuthDialogView", owner: nil, options: nil)!.first as! AuthDialogView
    }
}
