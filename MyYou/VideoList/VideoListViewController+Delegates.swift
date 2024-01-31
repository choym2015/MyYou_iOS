//
//  VideoListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation
import UIKit
import Alamofire

extension VideoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        
        let videoItem = self.videos[indexPath.row]
        
        cell.videoTitle.text = videoItem.title.removingPercentEncoding
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        if Manager2.shared.user.thumbnail {
            if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.youtubeID))/maxresdefault.jpg") {
                cell.videoImageView.downloadImage(from: url)
            } else if let url = URL(string: "https://img.youtube.com/vi/\(String(describing: videoItem.youtubeID))/default.jpg") {
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
        let time = MyUserDefaults.getString(with: "video_\(videoItem.youtubeID)_time")
        
        DispatchQueue.main.async {
            let youtubePlayerVC = YoutubeViewController(nibName: "YoutubeViewController", bundle: Bundle.main).receiveItem(index: indexPath.row, videoList: self.videos, time: time ?? "")
            youtubePlayerVC.modalPresentationStyle = .fullScreen
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.myOrientation = .landscape
            
            self.present(youtubePlayerVC, animated: true)
        }
    }
    
    func adjustTextViewHeight(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textHeightConstraint.constant = newSize.height
        self.view.layoutIfNeeded()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight(textView: textView)
    }
}
