//
//  CategoryListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import Foundation
import UIKit
import Alamofire

extension CategoryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryListViewCell", for: indexPath) as? CategoryListViewCell else { return UICollectionViewCell() }
        
        let category = self.categories[indexPath.row]
        
        cell.titleLabel.font = .boldSystemFont(ofSize: 17)
        cell.titleLabel.text = category.categoryName
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.titleLabel.backgroundColor = .white
        
        if category.categoryName == "사용법" || category.categoryName == "설정" || !category.isOwner() {
            cell.titleLabel.textColor = .lightGray
            cell.isUserInteractionEnabled = false
        } else {
            cell.titleLabel.textColor = .black
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = self.categories[indexPath.row]
        self.editCategory(category: category)
    }
}
