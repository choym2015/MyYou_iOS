//
//  NextTimeDialogView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/22/24.
//

import UIKit

class NextTimeDialogView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> NextTimeDialogView {
        return Bundle.main.loadNibNamed("NextTimeDialogView", owner: nil, options: nil)!.first as! NextTimeDialogView
    }
}
