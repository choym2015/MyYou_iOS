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
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var videoIDs = Manager2.shared.getVideoIDs()
        
        guard let firstItem = videoIDs.first,
              let videoID = self.videoID,
              let title = self.titleTextField.text else { return }
        
        if firstItem.isEmpty {
            videoIDs[0] = videoID
        } else {
            videoIDs.insert(videoID, at: 0)
        }
        
        let listString = videoIDs.joined(separator: ",")
        
        let params: Parameters = [
            "userID" : Manager2.shared.getUserID(),
            "videoID" : videoID,
            "title" : title,
            "categoryName" : "",
            "categoryID" : "",
            "videoIDs" : listString
        ]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable2/create_product.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
                }

//                self.updateCategory {
//                    self.tabNames = Manager2.shared.getCategoryNames()
//                    
//                    DispatchQueue.main.async {
//                        self.populateViewControllers()
//                    }
//                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
