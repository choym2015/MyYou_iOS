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
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var cancelImage: UIImageView!
    @IBOutlet weak var videoCategoryButton: UIButton!
    @IBOutlet weak var videoEditButton: UIButton!
    @IBOutlet weak var videoDeleteButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var videoID: String!
    
    func receiveItem(videoID: String) {
        self.videoID = videoID
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> VideoEditView {
        return Bundle.main.loadNibNamed("VideoEditView", owner: nil, options: nil)!.first as! VideoEditView
    }
}
