//
//  VideoListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation
import UIKit

extension VideoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        
        let videoItem = self.videos[indexPath.row]
        
        cell.videoTitle.text = videoItem.title
        
        if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.videoID))/maxresdefault.jpg") {
            cell.videoImageView.downloadImage(from: url)
        } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.videoID))/default.jpg") {
            cell.videoImageView.downloadImage(from: url)
        } else {
            cell.videoImageView.isHidden = true
        }
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
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
        
        database.collection(userID).document("video_" + videoItem.videoID).getDocument { documentSnaptshot, error in
            guard let documentSnapshot = documentSnaptshot,
                let time = documentSnapshot.get("time") as? String else { return }

            
            DispatchQueue.main.async {
                let youtubePlayerVC = YoutubeViewController(nibName: "YoutubeViewController", bundle: Bundle.main).receiveItem(index: indexPath.row, videoList: self.videos, time: time)
                
                self.present(youtubePlayerVC, animated: true)                
            }
        }
    }
}
