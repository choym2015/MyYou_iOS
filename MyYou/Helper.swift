//
//  Helper.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/23/24.
//

import Foundation

public class Helper {
    public static func getCategory(categoryID: String) -> Category? {
        guard let index = Manager2.shared.user.categoryIDs.firstIndex(of: categoryID) else {
            return nil
        }
        
        return Manager2.shared.user.categories[index]
    }
    
    public static func getCategory(categoryName: String?) -> Category? {
        guard let categoryName = categoryName else { return nil }
        
        return Manager2.shared.user.categories.first { category in
            category.categoryName == categoryName
        }
    }
    
    public static func getMyCategory(categoryName: String?) -> Category? {
        guard let categoryName = categoryName else { return nil }
        
        return Manager2.shared.user.categories.first { category in
            category.categoryName == categoryName && category.isOwner()
        }
    }
    
    public static func getCategoryForCategoryID(categoryID: String) -> Category? {
        guard let index = Manager2.shared.user.categoryIDs.firstIndex(of: categoryID) else {
            return nil
        }
        
        return Manager2.shared.user.categories[index]
    }
    
}
