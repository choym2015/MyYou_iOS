//
//  VideoEditView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import Foundation
import UIKit

class VideoEditView: UIView {
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoTitleTextField: UITextField!
    @IBOutlet weak var videoCategoryButton: UIButton!
    
    @IBOutlet weak var videoAddButton: UIButton!
    @IBOutlet weak var videoDeleteButton: UIButton!
    @IBOutlet weak var cancelImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> VideoEditView {
        return Bundle.main.loadNibNamed("VideoEditView", owner: nil, options: nil)!.first as! VideoEditView
    }
}
