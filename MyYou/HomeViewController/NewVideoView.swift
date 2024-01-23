//
//  NewVideoView.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/22/24.
//

import UIKit
import Alamofire

class NewVideoView: UIView {

    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleTextField: UITextView!
    
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
