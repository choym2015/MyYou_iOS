//
//  SelectCategoryView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import UIKit

class SelectCategoryView: UIView {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> SelectCategoryView {
        return Bundle.main.loadNibNamed("SelectCategoryView", owner: nil, options: nil)!.first as! SelectCategoryView
    }

}
