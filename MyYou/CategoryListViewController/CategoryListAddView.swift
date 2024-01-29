//
//  CategoryListAddView.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 1/25/24.
//

import Foundation
import UIKit

class CategoryListAddView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var completeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> CategoryListAddView {
        return Bundle.main.loadNibNamed("CategoryListAddView", owner: nil, options: nil)!.first as! CategoryListAddView
    }

}
