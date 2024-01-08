//
//  CategoryListViewController+Delegates.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/8/24.
//

import Foundation
import UIKit

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListTableViewCell", for: indexPath) as? CategoryListTableViewCell else { return UITableViewCell() }
        
        cell.categoryLabel.text = self.categories[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoryTableView.deselectRow(at: indexPath, animated: true)
        let category = self.categories[indexPath.row]
        self.editCategory(oldCategory: category)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.categories[indexPath.row]
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        let mover = self.categories.remove(at: sourceIndexPath.row)
        self.categories.insert(mover, at: destinationIndexPath.row)
        
        var updatedCategories = self.categories
        
        if self.showAll {
            updatedCategories.insert("전체영상", at: 0)
        }
        
        updatedCategories.append("설정")
        let documentReference = self.database.collection(userID).document("categories")
        documentReference.updateData(["order" : updatedCategories])
        NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
    }
}
