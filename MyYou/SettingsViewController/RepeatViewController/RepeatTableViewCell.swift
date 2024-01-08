//
//  RepeatTableViewCell.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/5/24.
//

import UIKit

class RepeatTableViewCell: UITableViewCell {

    @IBOutlet weak var repeatLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.accessoryType = selected ? .checkmark : .none
    }
}
