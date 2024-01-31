//
//  SelectCategoryToSendViewController+Delegate.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/30/24.
//

import Foundation
import UIKit

extension SelectCategoryToSendViewController: UITableViewDelegate, UITableViewDataSource {
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
        self.nextButton.isEnabled = true
    }
}
