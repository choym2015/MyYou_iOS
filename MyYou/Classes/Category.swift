//
//  Category.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/16/24.
//

import Foundation

public class Category: Decodable {
    let categoryID: String
    let ownerID: String
    let referenceCategoryID: String
    let categoryName: String
    var videoIDs: [String]
    
    init(categoryID: String, ownerID: String, referenceCategoryID: String, categoryName: String, videoIDs: [String]) {
        self.categoryID = categoryID
        self.ownerID = ownerID
        self.referenceCategoryID = referenceCategoryID
        self.categoryName = categoryName
        self.videoIDs = videoIDs
    }
    
    enum CodingKeys: CodingKey {
        case categoryID
        case ownerID
        case referenceCategoryID
        case categoryName
        case videoIDs
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categoryID = try container.decode(String.self, forKey: .categoryID)
        self.ownerID = try container.decode(String.self, forKey: .ownerID)
        self.referenceCategoryID = try container.decode(String.self, forKey: .referenceCategoryID)
        self.categoryName = try container.decode(String.self, forKey: .categoryName)
        
        if let videoIDsString = try? container.decode(String.self, forKey: .videoIDs),
           !videoIDsString.isEmpty {
            self.videoIDs = videoIDsString.components(separatedBy: ",")
        } else {
            self.videoIDs = []
        }
    }
    
    public func isOwner() -> Bool {
        return referenceCategoryID.isEmpty
    }
    
    public func addVideoID(videoID: String) {
        if self.videoIDs.isEmpty {
            self.videoIDs.append(videoID)
        } else if self.videoIDs[0].isEmpty {
            self.videoIDs[0] = videoID
        } else {
            self.videoIDs.append(videoID)
        }
    }
    
    public func removeVideoID(videoID: String) {
        if let index = self.videoIDs.firstIndex(of: videoID) {
            self.videoIDs.remove(at: index)
        }
    }
}
