//
//  Manager2.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/22/24.
//

import Foundation

public class Manager2 {
    public static let shared = Manager2()
    
    public var user: User2!
    public var androidFCMKey: String!
    
    public func setUser(user: User2) {
        if user.categoryIDs.count != user.categories.count {
            let categoryIds: [String] = user.categories.map { category in
                category.categoryID
            }
            
            let cleanedCategoryIDs = user.categoryIDs.filter { categoryID in
                categoryIds.contains(categoryID)
            }
            
            NetworkManager.updateCategoryIDs(categoryIDs: cleanedCategoryIDs) { response in
                switch response.result {
                case .success:
                    print("CATEGORY IDS CLEANED")
                case .failure:
                    print("ERROR UPDATING CATEGORY IDS")
                }
            }
        }
        
        let videoItems: [String] = user.videoItems.map { videoItem in
            videoItem.videoID
        }

        for category in user.categories {
            let cleanedVideoIDs: [String] = category.videoIDs.filter { videoID in
                videoItems.contains(videoID)
            }
            
            if cleanedVideoIDs.count != category.videoIDs.count {
                NetworkManager.updateCategoryVideoIDs(category: category, videoIDs: cleanedVideoIDs) { response in
                    switch response.result {
                    case .success:
                        print("CATEGORY VIDEO IDS CLEANED")
                    case .failure:
                        print("ERROR UPDATING CATEGORY VIDEO IDS")
                    }
                }
                
                category.videoIDs = cleanedVideoIDs
            }
            
            if !user.duplicateVideoIDs.isEmpty && !category.referenceCategoryID.isEmpty {
                let referenceCategoryVideoIDs = category.videoIDs
                var cleanedReferenceCategoryVideoIDs: [String] = []
                
                for referenceCategoryVideoID in referenceCategoryVideoIDs {
                    if let index = user.duplicateVideoIDs.firstIndex(of: referenceCategoryVideoID) {
                        user.duplicateVideoIDs.remove(at: index)
                    } else {
                        cleanedReferenceCategoryVideoIDs.append(referenceCategoryVideoID)
                    }
                }
                
                if cleanedReferenceCategoryVideoIDs.count != category.videoIDs.count {
                    NetworkManager.updateCategoryVideoIDs(category: category, videoIDs: cleanedReferenceCategoryVideoIDs) { response in
                        switch response.result {
                        case .success:
                            print("REFERENCE CATEGORY VIDEO IDS CLEANED")
                        case .failure:
                            print("ERROR UPDATING REFERENCE CATEGORY VIDEO IDS")
                        }
                    }
                    category.videoIDs = cleanedReferenceCategoryVideoIDs
                }
            }
        }

        Manager2.shared.user = user
    }
    
    public func getUserID() -> String {
        return Manager2.shared.user.userID
    }
    
    public func getCategoryNames() -> [String] {
        return Manager2.shared.user.categories.map({ category in
            category.categoryName
        })
    }
    
    public func getCategoryIDs() -> [String] {
        return Manager2.shared.user.categoryIDs
    }
    
    public func getCategories() -> [Category] {
        return Manager2.shared.user.categories
    }
    
    public func getUserPhoneNumber() -> String {
        return Manager2.shared.user.userPhoneNumber
    }
    
    public func getAndroidFCMKey() -> String {
        return Manager2.shared.androidFCMKey
    }
}

public class User2: Decodable {
    var thumbnail: Bool
    var playNext: Bool
    var pushEnabled: Bool
    var newMessage: Bool
    var selectedRepeatSelection: String
    var userPhoneNumber: String
    var lastCategoryID: String
    var userID: String
    var playbackSpeed: String
    var subscription: String
    var categories: [Category]
    var videoItems: [VideoItem]
    var repeatSelections: [String]
    var categoryIDs: [String]
    var duplicateVideoIDs: [String]
    
    enum CodingKeys: CodingKey {
        case thumbnail
        case playNext
        case pushEnabled
        case newMessage
        case selectedRepeatSelection
        case userPhoneNumber
        case lastCategoryID
        case userID
        case playbackSpeed
        case subscription
        case categories
        case videoItems
        case repeatSelection
        case duplicateVideoIDs
        case categoryIDs
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.thumbnail = try container.decode(String.self, forKey: .thumbnail) == "true" ? true : false
        self.playNext = try container.decode(String.self, forKey: .playNext) == "true" ? true : false
        self.pushEnabled = try container.decode(String.self, forKey: .pushEnabled) == "true" ? true : false
        self.newMessage = try container.decode(String.self, forKey: .newMessage) == "true" ? true : false
        self.selectedRepeatSelection = try container.decode(String.self, forKey: .selectedRepeatSelection)
        self.userPhoneNumber = try container.decode(String.self, forKey: .userPhoneNumber)
        self.lastCategoryID = try container.decode(String.self, forKey: .lastCategoryID)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.playbackSpeed = try container.decode(String.self, forKey: .playbackSpeed)
        self.subscription = try container.decode(String.self, forKey: .subscription)
        self.categories = try container.decode([Category].self, forKey: .categories)
        self.videoItems = try container.decode([VideoItem].self, forKey: .videoItems)
        
        if let repeatSelectionsString = try? container.decode(String.self, forKey: .repeatSelection) {
            self.repeatSelections = repeatSelectionsString.components(separatedBy: ",")
        } else {
            self.repeatSelections = []
        }
        
        if let duplicateVideoIDsString = try? container.decode(String.self, forKey: .duplicateVideoIDs),
           !duplicateVideoIDsString.isEmpty {
            self.duplicateVideoIDs = duplicateVideoIDsString.components(separatedBy: ",")
        } else {
            self.duplicateVideoIDs = []
        }
        
        if let categoryIDsString = try? container.decode(String.self, forKey: .categoryIDs) {
            self.categoryIDs = categoryIDsString.components(separatedBy: ",")
        } else {
            self.categoryIDs = []
        }
    }
}
