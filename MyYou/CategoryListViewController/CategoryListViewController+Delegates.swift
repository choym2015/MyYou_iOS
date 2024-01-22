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
        
        cell.titleLabel.font = .boldSystemFont(ofSize: 17)
        cell.titleLabel.text = self.videoCategories[indexPath.row]
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.titleLabel.backgroundColor = .white
        cell.titleLabel.textColor = .black
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      //  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryListViewCell", for: indexPath) as! CategoryListViewCell
      //  let newSize = cell.contentView.sizeThatFits(CGSize(width: cell.frame.width, height: CGFloat.leastNormalMagnitude))
        return CGSize(width: collectionView.frame.width - 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = self.videoCategories[indexPath.row]
        self.editCategory(oldCategory: category)
    }
    
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryListTableViewCell", for: indexPath) as? CategoryListTableViewCell else { return UITableViewCell() }
        
        cell.categoryLabel.text = self.videoCategories[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoryTableView.deselectRow(at: indexPath, animated: true)
        let category = self.videoCategories[indexPath.row]
        self.editCategory(oldCategory: category)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = self.videoCategories[indexPath.row]
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = self.videoCategories.remove(at: sourceIndexPath.row)
        self.videoCategories.insert(mover, at: destinationIndexPath.row)
        
        var updatedCategories = self.videoCategories
        
        if let firstCategory = self.categories.first,
           firstCategory == "전체영상" {
            updatedCategories.insert("전체영상", at: 0)
        }
        
        updatedCategories.append("설정")
        
        let listString = updatedCategories.joined(separator: ",")
        let params: Parameters = ["categories" : listString, "userID" : self.userID]
        
        AF.request("https://chopas.com/smartappbook/myyou/categoryTable/update_categories.php/",
                   method: .post,
                   parameters: params,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/x-www-form-urlencoded", "Accept":"application/x-www-form-urlencoded"])
        
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SimpleResponse<String>.self, completionHandler: { response in
            switch response.result {
            case .success:
                Manager.shared.setCategories(categories: updatedCategories)
                self.categories = updatedCategories
                self.videoCategories = updatedCategories
                self.videoCategories.removeAll { category in
                    category == "전체영상" || category == "설정"
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("updateCategory"), object: nil)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        })
    }*/
}
