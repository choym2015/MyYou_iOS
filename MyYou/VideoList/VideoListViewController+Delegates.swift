//
//  VideoListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation
import UIKit
import Alamofire

extension VideoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        
        let videoItem = self.videos[indexPath.row]
        
        cell.videoTitle.text = videoItem.title
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        if Manager2.shared.user.thumbnail {
            if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.videoID))/maxresdefault.jpg") {
                cell.videoImageView.downloadImage(from: url)
            } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.videoID))/default.jpg") {
                cell.videoImageView.downloadImage(from: url)
            } else {
                cell.videoImageView.isHidden = true
            }
        } else {
            cell.videoImageView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoItem = self.videos[indexPath.row]
        
        let params: Parameters = ["userID" : Manager2.shared.getUserID(), "videoID": videoItem.videoID]
        
        AF.request("https://chopas.com/smartappbook/myyou/videoTable/get_videos_by_id.php/",
                   method: .get,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: VideoItemList.self, completionHandler: { response in
            switch response.result {
            case .success:
                guard let videoItemList = response.value,
                      let selectedVideoItem = videoItemList.product.first else { return }
                
                DispatchQueue.main.async {
                    let youtubePlayerVC = YoutubeViewController(nibName: "YoutubeViewController", bundle: Bundle.main).receiveItem(index: indexPath.row, videoList: self.videos, time: "selectedVideoItem.time")
                    youtubePlayerVC.modalPresentationStyle = .fullScreen
                    
                    self.present(youtubePlayerVC, animated: true)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }
}
