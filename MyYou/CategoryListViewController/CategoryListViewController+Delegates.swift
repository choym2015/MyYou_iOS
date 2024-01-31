//
//  CategoryListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import Foundation
import UIKit
import Alamofire
import JDStatusBarNotification

extension CategoryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
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
        
        if category.categoryName == "임시" {
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
        
        NetworkManager.getReferenceUsersForCategory(category: category) { response in
            switch response.result {
            case .success:
                if let audiences = response.value?.product,
                   !audiences.isEmpty {
                    
                } else {
                    self.editCategory(category: category)
                }
            
                
            case .failure(let err):
                NotificationPresenter.shared.present(err.localizedDescription, includedStyle: .error, duration: 2.0)
            }
        }        
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession != nil {
            if destinationIndexPath?.row == 0{
                return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
            }
            
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    
        return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              destinationIndexPath.row != 0 else {
            return
        }
        
        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath,
                sourceIndexPath.row != 0 else { return }
            let categoryCell = self.categories[sourceIndexPath.row]
            
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                self.categories.remove(at: sourceIndexPath.row)
                self.categories.insert(categoryCell, at: destinationIndexPath.row)
            }, completion: { _ in
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
                
                let categoryIDs = self.categories.map { $0.categoryID }
                NetworkManager.updateCategoryIDs(categoryIDs: categoryIDs) { response in
                    switch response.result {
                    case .success:
                        HomeViewController.reload {
                            NotificationCenter.default.post(name: Notification.Name("reloadCategory"), object: nil)
                        }
                    case .failure(let failure):
                        NotificationPresenter.shared.present(failure.localizedDescription, includedStyle: .error, duration: 2.0)
                    }
                }
                NetworkManager.updateCategoryIDs(categoryIDs: categoryIDs) { _ in }
            })
            
        }
    }
}
