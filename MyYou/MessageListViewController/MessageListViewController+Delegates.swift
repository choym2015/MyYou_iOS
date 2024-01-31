//
//  MessageListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import Foundation
import UIKit

extension MessageListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageItemCollectionViewCell", for: indexPath) as? MessageItemCollectionViewCell else { return UICollectionViewCell() }
        
        let message = self.messages[indexPath.row]
        
        cell.titleLabel.font = .boldSystemFont(ofSize: 17)
        cell.titleLabel.text = message.category.categoryName
        cell.dateLabel.text = message.timestamp
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.titleLabel.backgroundColor = .white
        
        if message.downloaded {
            cell.downloadedImageView.image = UIImage(named: "approval")
        }
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = self.messages[indexPath.row]
        
        let downloadMessageVC = DownloadMessageViewController(nibName: "DownloadMessageViewController", bundle: Bundle.main)
        downloadMessageVC.modalPresentationStyle = .fullScreen
        downloadMessageVC.receiveItem(message: message) { needUpdate in
            if needUpdate {
                self.loadMessages()
            }
        }
        
        self.navigationController?.pushViewController(downloadMessageVC, animated: true)
    }
}
