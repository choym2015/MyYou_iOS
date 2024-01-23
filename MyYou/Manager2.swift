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
    
    public func setUser(user: User2) {
        Manager2.shared.user = user
    }
    
    public func getUserID() -> String {
        return Manager2.shared.user.userID
    }
    
    public func getVideoIDs() -> [String] {
        return Manager2.shared.user.videoIDs
    }
    
    public func getCategoryNames() -> [String] {
        return Manager2.shared.user.categories.map({ category in
            category.categoryName
        })
    }
    
    public func getCategories() -> [Category] {
        return Manager2.shared.user.categories
    }
}

public class User2: Decodable {
    var thumbnail: Bool!
    var playNext: Bool!
    var pushEnabled: Bool!
    var newMessage: Bool!
    var showAll: Bool!
    var selectedRepeatSelection: String!
    var userPhoneNumber: String!
    var lastCategory: String!
    var userID: String!
    var playbackSpeed: String!
    var subscription: String!
    var categories: [Category]!
    var videoItems: [VideoItem]!
    var repeatSelections: [String]!
    var videoIDs: [String]!
    var categoryIDs: [String]!
    
    enum CodingKeys: CodingKey {
        case thumbnail
        case playNext
        case pushEnabled
        case newMessage
        case showAll
        case selectedRepeatSelection
        case userPhoneNumber
        case lastCategory
        case userID
        case playbackSpeed
        case subscription
        case categories
        case videoItems
        case repeatSelection
        case videoIDs
        case categoryIDs
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.thumbnail = try container.decode(String.self, forKey: .thumbnail) == "true" ? true : false
        self.playNext = try container.decode(String.self, forKey: .playNext) == "true" ? true : false
        self.pushEnabled = try container.decode(String.self, forKey: .pushEnabled) == "true" ? true : false
        self.newMessage = try container.decode(String.self, forKey: .newMessage) == "true" ? true : false
        self.showAll = try container.decode(String.self, forKey: .showAll) == "true" ? true : false
        self.selectedRepeatSelection = try container.decodeIfPresent(String.self, forKey: .selectedRepeatSelection)
        self.userPhoneNumber = try container.decodeIfPresent(String.self, forKey: .userPhoneNumber)
        self.lastCategory = try container.decodeIfPresent(String.self, forKey: .lastCategory)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.playbackSpeed = try container.decodeIfPresent(String.self, forKey: .playbackSpeed)
        self.subscription = try container.decodeIfPresent(String.self, forKey: .subscription)
        self.categories = try container.decodeIfPresent([Category].self, forKey: .categories)
        self.videoItems = try container.decodeIfPresent([VideoItem].self, forKey: .videoItems)
        
        if let repeatSelectionsString = try? container.decode(String.self, forKey: .repeatSelection) {
            self.repeatSelections = repeatSelectionsString.components(separatedBy: ",")
        }
        
        if let videoIDsString = try? container.decode(String.self, forKey: .videoIDs) {
            self.videoIDs = videoIDsString.components(separatedBy: ",")
        }
        
        if let categoryIDsString = try? container.decode(String.self, forKey: .categoryIDs) {
            self.categoryIDs = categoryIDsString.components(separatedBy: ",")
        }
        
        if self.showAll {
            let showAllCategory = Category(categoryID: "showAll", ownerID: self.userID, audienceID: "", categoryName: "전체영상")
            self.categories.insert(showAllCategory, at: 0)
        }
        
        let settingsCategory = Category(categoryID: "settings", ownerID: self.userID, audienceID: "", categoryName: "설정")
        self.categories.append(settingsCategory)
    }
}
