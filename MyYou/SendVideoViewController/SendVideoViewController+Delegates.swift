//
//  SendVideoViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import Foundation
import UIKit

extension SendVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SendVideoCollectionViewCell", for: indexPath) as? SendVideoCollectionViewCell else { return UICollectionViewCell() }
        
        let phoneNumber = self.phoneNumbers[indexPath.row]
        
        cell.titleLabel.font = .boldSystemFont(ofSize: 17)
        cell.titleLabel.text = phoneNumber
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.titleLabel.backgroundColor = .white
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.phoneNumbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.phoneNumbers.remove(at: indexPath.row)
        self.collectionView.reloadData()
        
        if self.phoneNumbers.isEmpty {
            self.nextButton.isEnabled = false
            self.emptyTextLabel.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatTableViewCell", for: indexPath) as? RepeatTableViewCell else { return UITableViewCell() }
        
        let category = self.categories[indexPath.row]
        
        cell.repeatLabel.text = category.categoryName
        
        if category.categoryName == "사용법" || category.categoryName == "임시" || !category.isOwner() {
            cell.selectionStyle = .none
            cell.repeatLabel.textColor = .lightGray
            cell.isUserInteractionEnabled = false
        } else {
            cell.selectionStyle = .default
            cell.repeatLabel.textColor = .black
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCategory = self.categories[indexPath.row]
        self.selectCategoryView?.sendButton.isEnabled = true
    }
}

