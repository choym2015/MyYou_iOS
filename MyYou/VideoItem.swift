//
//  VideoItem.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation

public struct VideoItem: Codable {
    let videoID: String
    let title: String
    let liked: Bool
    let time: String
    let category: String
    let premium: Bool
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        videoID = try values.decode(String.self, forKey: .videoID)
        title = try values.decode(String.self, forKey: .title)
        time = try values.decode(String.self, forKey: .time)
        category = try values.decode(String.self, forKey: .category)
        
        let likedString = try values.decode(String.self, forKey: .liked)
        liked = likedString == "true" ? true : false
        
        let premiumString = try values.decode(String.self, forKey: .premium)
        premium = premiumString == "true" ? true : false
    }
    
    private enum CodingKeys: String, CodingKey {
        case videoID, title, liked, time, category, premium
    }
}




public struct VideoItemList: Codable {
    let product: [VideoItem]
}
