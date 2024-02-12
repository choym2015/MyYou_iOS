//
//  ErrorDialogView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/31/24.
//

import UIKit

class ErrorDialogView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> ErrorDialogView {
        return Bundle.main.loadNibNamed("ErrorDialogView", owner: nil, options: nil)!.first as! ErrorDialogView
    }
}
