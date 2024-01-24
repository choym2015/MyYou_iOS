//
//  NewVideoView2.swift
//  MyYou
//
//  Created by SOO HYUN CHO on 1/23/24.
//

import UIKit

class NewVideoView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var videoID: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func instantiateFromNib() -> NewVideoView {
        return Bundle.main.loadNibNamed("NewVideoView", owner: nil, options: nil)!.first as! NewVideoView
    }
    
    func receiveItem(videoID: String) {
        self.videoID = videoID
    }
}
