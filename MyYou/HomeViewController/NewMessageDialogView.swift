//
//  NewMessageDialogView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/31/24.
//

import UIKit

class NewMessageDialogView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> NewMessageDialogView {
        return Bundle.main.loadNibNamed("NewMessageDialogView", owner: nil, options: nil)!.first as! NewMessageDialogView
    }

}
