//
//  SelectVideoToSendViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/30/24.
//

import Foundation
import UIKit

extension SelectVideoToSendViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else { return UICollectionViewCell() }
        
        let videoItem = self.videos[indexPath.row]
        
        cell.videoTitle.text = videoItem.title.removingPercentEncoding
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.youtubeID))/maxresdefault.jpg") {
            cell.videoImageView.downloadImage(from: url)
        } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.youtubeID))/default.jpg") {
            cell.videoImageView.downloadImage(from: url)
        } else {
            cell.videoImageView.isHidden = true
        }
        
        if self.shouldSend[indexPath.row] {
            cell.alpha = 1.0
            cell.contentView.alpha = 1.0
        } else {
            cell.alpha = 0.2
            cell.contentView.alpha = 0.2
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
        
        guard videoItem.isOwner() else { return }
        
        let isSelected = self.shouldSend[indexPath.row]
        self.shouldSend[indexPath.row] = !isSelected
        
        self.collectionView.reloadData()
    }
}

