//
//  MessageItem.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/24/24.
//

import Foundation

public struct MessageItem: Decodable {
    let timestamp: String
    let messageID: String
    let videoIDs: String
    let downloaded: Bool
    let category: Category
    
    enum CodingKeys: CodingKey {
        case timestamp
        case messageID
        case downloaded
        case category
        case videoIDs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.messageID = try container.decode(String.self, forKey: .messageID)
        self.category = try container.decode(Category.self, forKey: .category)
        self.downloaded = try container.decode(String.self, forKey: .downloaded) == "true" ? true : false
        self.videoIDs = try container.decode(String.self, forKey: .videoIDs)
    }
}

public struct MessageItemList: Decodable {
    let product: [MessageItem]
}
