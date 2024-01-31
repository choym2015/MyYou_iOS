//
//  VideoItem.swift
//  MyYou
//
//  Created by Youngmin Cho on 12/29/23.
//

import Foundation

public class VideoItem: Decodable {
    let ownerID: String
    let videoID: String
    var title: String
    let youtubeID: String
    
    enum CodingKeys: CodingKey {
        case ownerID
        case videoID
        case title
        case youtubeID
    }
    
    public func isOwner() -> Bool {
        return self.ownerID == Manager2.shared.getUserID()
    }
}


public struct VideoItemList: Decodable {
    let product: [VideoItem]
}
